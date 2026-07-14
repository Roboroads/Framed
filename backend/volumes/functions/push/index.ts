// Framed data-only push (issue #27). Triggered by a `push_outbox` insert
// (backend/volumes/db/init/24-push.sql); sweeps every unsent row, sends a
// content-free wake-up to FCM (Android) or APNs (iOS) per player, stamps
// sent_at. The device decrypts and renders locally (#28) — this function
// never sees or sends a name, photo, or ciphertext, only {event, game_id}.
//
// No provider keys configured (the local dev default — see #27's decision
// comment, real key provisioning is separate): logs one line per would-be
// push instead of sending, and still marks the row sent. A queue that
// backs up waiting for keys that will never exist defeats the point of
// "best-effort" push.
import { createClient } from 'jsr:@supabase/supabase-js@2'
import * as jose from 'jsr:@panva/jose@6'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const FCM_SERVICE_ACCOUNT_JSON = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON')
const APNS_KEY_P8 = Deno.env.get('APNS_KEY_P8')
const APNS_KEY_ID = Deno.env.get('APNS_KEY_ID')
const APNS_TEAM_ID = Deno.env.get('APNS_TEAM_ID')
const APNS_BUNDLE_ID = Deno.env.get('APNS_BUNDLE_ID') ?? 'me.roboroads.framed'

const KEYS_CONFIGURED = Boolean(FCM_SERVICE_ACCOUNT_JSON || APNS_KEY_P8)

const client = createClient(SUPABASE_URL, SERVICE_ROLE_KEY)

interface OutboxRow {
  id: string
  event: string
  game_id: string
  players: { push_token: string | null; platform: string | null } | null
}

Deno.serve(async () => {
  const { data: rows, error } = await client
    .from('push_outbox')
    .select('id, event, game_id, players(push_token, platform)')
    .is('sent_at', null)

  if (error) {
    console.error('push: failed to read outbox', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const sentIds: string[] = []
  for (const row of (rows ?? []) as unknown as OutboxRow[]) {
    try {
      await sendOne(row)
    } catch (e) {
      // Best-effort by design (IDEA.md "Known risks") — a bad token or a
      // provider outage drops this one push, not the sweep.
      console.error(`push: send failed for outbox row ${row.id}`, e)
    }
    sentIds.push(row.id)
  }

  if (sentIds.length > 0) {
    await client
      .from('push_outbox')
      .update({ sent_at: new Date().toISOString() })
      .in('id', sentIds)
  }

  return new Response(JSON.stringify({ sent: sentIds.length }), {
    headers: { 'Content-Type': 'application/json' },
  })
})

async function sendOne(row: OutboxRow) {
  const token = row.players?.push_token
  const platform = row.players?.platform
  if (!token) return // no token on file — nothing to wake up

  if (!KEYS_CONFIGURED) {
    console.log(
      `push (no keys configured): would send {event: ${row.event}, game_id: ${row.game_id}} to ${platform ?? 'unknown'} token ${token}`,
    )
    return
  }

  if (platform === 'ios' && APNS_KEY_P8) {
    await sendApns(token, row)
    return
  }
  if (platform === 'android' && FCM_SERVICE_ACCOUNT_JSON) {
    await sendFcm(token, row)
    return
  }
  console.error(`push: no provider key configured for platform ${platform}`)
}

// FCM HTTP v1: exchange the service account for a short-lived OAuth2
// access token (RS256 JWT assertion), then send. `priority: high` per
// IDEA.md "Notifications" — this is the pocket-wakeup path.
async function sendFcm(token: string, row: OutboxRow) {
  const account = JSON.parse(FCM_SERVICE_ACCOUNT_JSON!) as {
    client_email: string
    private_key: string
    project_id: string
  }
  const key = await jose.importPKCS8(account.private_key, 'RS256')
  const assertion = await new jose.SignJWT({
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  })
    .setProtectedHeader({ alg: 'RS256' })
    .setIssuer(account.client_email)
    .setAudience('https://oauth2.googleapis.com/token')
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(key)

  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  })
  const { access_token } = (await tokenResponse.json()) as {
    access_token: string
  }

  await fetch(
    `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          data: { event: row.event, game_id: row.game_id },
          android: { priority: 'high' },
        },
      }),
    },
  )
}

// APNs token-based auth: an ES256 JWT signed with the .p8 key, cached per
// cold start (APNs allows the same provider token across many pushes for
// up to an hour). Background push: content-available only, no alert — the
// client renders its own time-sensitive local notification (#28).
let cachedApnsJwt: { token: string; expiresAt: number } | null = null

async function apnsProviderToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  if (cachedApnsJwt && cachedApnsJwt.expiresAt > now + 60) {
    return cachedApnsJwt.token
  }
  const key = await jose.importPKCS8(APNS_KEY_P8!, 'ES256')
  const token = await new jose.SignJWT({})
    .setProtectedHeader({ alg: 'ES256', kid: APNS_KEY_ID })
    .setIssuer(APNS_TEAM_ID!)
    .setIssuedAt(now)
    .sign(key)
  cachedApnsJwt = { token, expiresAt: now + 3000 }
  return token
}

async function sendApns(token: string, row: OutboxRow) {
  const providerToken = await apnsProviderToken()
  await fetch(`https://api.push.apple.com/3/device/${token}`, {
    method: 'POST',
    headers: {
      authorization: `bearer ${providerToken}`,
      'apns-topic': APNS_BUNDLE_ID,
      'apns-push-type': 'background',
      'apns-priority': '5',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      aps: { 'content-available': 1 },
      event: row.event,
      game_id: row.game_id,
    }),
  })
}
