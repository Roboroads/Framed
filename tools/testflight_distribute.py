#!/usr/bin/env python3
"""Add the just-uploaded TestFlight build to a public-link beta group.

Run by CI after apple-actions/upload-testflight-build: the upload only
parks the build in App Store Connect, it does not reach any tester
group. This script waits for App Store Connect to finish processing the
build, adds it to the external beta group named by TESTFLIGHT_GROUP_NAME
(the group whose public link testers join with), and submits it for beta
review, which the group's first build requires before the link serves it.

Env: APPSTORE_ISSUER_ID, APPSTORE_KEY_ID, APPSTORE_API_KEY_BASE64
(the .p8, base64), TESTFLIGHT_GROUP_NAME, BUILD_NUMBER. Needs pyjwt and
cryptography. Unverified against a real App Store Connect account, like
the rest of the iOS pipeline; expect to iterate on first contact.
"""

import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request

import jwt

ISSUER = os.environ["APPSTORE_ISSUER_ID"]
KEY_ID = os.environ["APPSTORE_KEY_ID"]
PRIVATE_KEY = base64.b64decode(os.environ["APPSTORE_API_KEY_BASE64"]).decode()
GROUP = os.environ["TESTFLIGHT_GROUP_NAME"]
BUILD_NUMBER = os.environ["BUILD_NUMBER"]
BUNDLE_ID = os.environ.get("BUNDLE_ID", "me.roboroads.framed")

# Processing routinely takes 5-15 minutes after upload; poll for 40.
POLL_SECONDS = 40
POLL_TRIES = 60


def token():
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        PRIVATE_KEY,
        algorithm="ES256",
        headers={"kid": KEY_ID},
    )


def api(method, path, body=None):
    req = urllib.request.Request(
        "https://api.appstoreconnect.apple.com" + path,
        method=method,
        data=json.dumps(body).encode() if body else None,
        headers={
            "Authorization": f"Bearer {token()}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        return {"_status": e.code, "_body": e.read().decode()}


def main():
    apps = api("GET", f"/v1/apps?filter[bundleId]={BUNDLE_ID}")
    if not apps.get("data"):
        sys.exit(f"app {BUNDLE_ID} not found: {apps}")
    app_id = apps["data"][0]["id"]

    build = None
    for attempt in range(POLL_TRIES):
        r = api(
            "GET",
            f"/v1/builds?filter[app]={app_id}"
            f"&filter[version]={BUILD_NUMBER}&limit=1",
        )
        data = r.get("data") or []
        if data:
            build = data[0]
            state = build["attributes"]["processingState"]
            print(f"build {BUILD_NUMBER}: {state}")
            if state == "VALID":
                break
            if state in ("FAILED", "INVALID"):
                sys.exit(f"build processing ended in {state}")
        else:
            print(f"build {BUILD_NUMBER} not visible yet ({attempt + 1})")
        time.sleep(POLL_SECONDS)
    else:
        sys.exit("build never finished processing")

    groups = api(
        "GET", f"/v1/betaGroups?filter[app]={app_id}&filter[name]={GROUP}"
    ).get("data")
    if not groups:
        sys.exit(f'beta group "{GROUP}" not found; create it in App Store Connect')
    group_id = groups[0]["id"]

    r = api(
        "POST",
        f"/v1/betaGroups/{group_id}/relationships/builds",
        {"data": [{"type": "builds", "id": build["id"]}]},
    )
    if r.get("_status") not in (None, 204):
        sys.exit(f"adding build to group failed: {r}")
    print(f'build added to group "{GROUP}"')

    # The group's first build must pass beta review before the public link
    # serves it. Later builds are usually waved through; an "already
    # submitted/reviewed" style error here is fine and not a failure.
    r = api(
        "POST",
        "/v1/betaAppReviewSubmissions",
        {
            "data": {
                "type": "betaAppReviewSubmissions",
                "relationships": {
                    "build": {"data": {"type": "builds", "id": build["id"]}}
                },
            }
        },
    )
    if r.get("_status") in (None, 201):
        print("submitted for beta review")
    else:
        print(f"beta review submission response (non-fatal): {r}")


if __name__ == "__main__":
    main()
