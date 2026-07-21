# Unverified translations

`es`/`fr`/`nl` strings in this folder are written by Claude, not a native
speaker or a translation vendor. `en` is the source of truth and always
correct by construction; the other three are a best effort until a human
fluent in that language checks them.

Why not a `// MT` comment directly in the `.i18n.json` files: slang parses
them with strict `jsonDecode` (see `slang-*/lib/src/builder/decoder/json_decoder.dart`
in the pub cache), which errors on anything that isn't valid JSON —
comments included. This file is the workaround: a checklist of dotted key
paths (the same path you'd write after `t.`, e.g. `t.lobby.leaveButton`)
still waiting on a human read-through, one per line, grouped by locale.

## Workflow

- Adding or editing an `es`/`fr`/`nl` line: add its key path under that
  locale below, unless you're already a fluent speaker confident in the
  wording.
- Verifying a line: open the three locale files at that key, check the
  wording reads naturally and matches the `en` meaning, then delete the
  line from this file. No checkbox to tick — a line's presence here *is*
  the marker, so clearing it is the whole action.
- A key that's been edited again since it was last verified goes back on
  the list.

## es

- [ ] frame.sendToJudges
- [ ] lobby.leaveButton
- [ ] lobby.leaveConfirmTitle
- [ ] lobby.leaveConfirmBody
- [ ] lobby.leaveConfirmButton
- [ ] ingame.deadLeaveButton
- [ ] ingame.deadLeaveWarning
- [ ] ingame.deadLeaveConfirmTitle
- [ ] ingame.deadLeaveConfirmBody
- [ ] ingame.deadLeaveConfirmButton
- [ ] finish.leaveConfirmTitle
- [ ] finish.leaveConfirmBody
- [ ] finish.leaveConfirmButton
- [ ] confirmationDialog.cancel
- [ ] ingame.wakeLockOnTooltip
- [ ] ingame.wakeLockOffTooltip
- [ ] ingame.leaveButton
- [ ] ingame.leaveConfirmTitle
- [ ] ingame.leaveConfirmBody
- [ ] ingame.leaveConfirmButton
- [ ] ingame.deadTitleLeft
- [ ] ingame.deadCauseLeft
- [ ] finish.killChainLeft
- [ ] finish.chatTitle
- [ ] finish.chatEmpty
- [ ] finish.chatHint
- [ ] finish.chatSendButton
- [ ] ingame.deadAlsoOut
- [ ] camera.permissionBlockedBody
- [ ] frame.cooldownReasonRejected
- [ ] frame.cooldownReasonTimeout
- [ ] ingame.leaveNetworkWarning
- [ ] lobby.joinSectionTitle
- [ ] lobby.keyLivesHere
- [ ] lobby.tapQrToEnlarge
- [ ] lobby.rosterSectionTitle
- [ ] lobby.playAreaSectionTitle
- [ ] lobby.modeSectionTitle
- [ ] lobby.waitingForPlayers
- [ ] camera.shutterLabel
- [ ] scan.instruction
- [ ] scan.locked
- [ ] preJoin.nameSectionTitle
- [ ] preJoin.faceSectionTitle
- [ ] preJoin.sharesSectionTitle
- [ ] preJoin.consentNotice (reworded: data only)
- [ ] preJoin.playSafeSectionTitle
- [ ] preJoin.playSafeNotice
- [ ] preJoin.agreeNotice
- [ ] common.close
- [ ] hostSetup.resetButton
- [ ] hostSetup.resetConfirmTitle
- [ ] hostSetup.resetConfirmBody
- [ ] hostSetup.resetConfirmButton

## fr

- [ ] frame.sendToJudges
- [ ] lobby.leaveButton
- [ ] lobby.leaveConfirmTitle
- [ ] lobby.leaveConfirmBody
- [ ] lobby.leaveConfirmButton
- [ ] ingame.deadLeaveButton
- [ ] ingame.deadLeaveWarning
- [ ] ingame.deadLeaveConfirmTitle
- [ ] ingame.deadLeaveConfirmBody
- [ ] ingame.deadLeaveConfirmButton
- [ ] finish.leaveConfirmTitle
- [ ] finish.leaveConfirmBody
- [ ] finish.leaveConfirmButton
- [ ] confirmationDialog.cancel
- [ ] ingame.wakeLockOnTooltip
- [ ] ingame.wakeLockOffTooltip
- [ ] ingame.leaveButton
- [ ] ingame.leaveConfirmTitle
- [ ] ingame.leaveConfirmBody
- [ ] ingame.leaveConfirmButton
- [ ] ingame.deadTitleLeft
- [ ] ingame.deadCauseLeft
- [ ] finish.killChainLeft
- [ ] finish.chatTitle
- [ ] finish.chatEmpty
- [ ] finish.chatHint
- [ ] finish.chatSendButton
- [ ] ingame.deadAlsoOut
- [ ] camera.permissionBlockedBody
- [ ] frame.cooldownReasonRejected
- [ ] frame.cooldownReasonTimeout
- [ ] ingame.leaveNetworkWarning

## nl

- [ ] frame.sendToJudges
- [ ] lobby.leaveButton
- [ ] lobby.leaveConfirmTitle
- [ ] lobby.leaveConfirmBody
- [ ] lobby.leaveConfirmButton
- [ ] ingame.deadLeaveButton
- [ ] ingame.deadLeaveWarning
- [ ] ingame.deadLeaveConfirmTitle
- [ ] ingame.deadLeaveConfirmBody
- [ ] ingame.deadLeaveConfirmButton
- [ ] finish.leaveConfirmTitle
- [ ] finish.leaveConfirmBody
- [ ] finish.leaveConfirmButton
- [ ] confirmationDialog.cancel
- [ ] ingame.wakeLockOnTooltip
- [ ] ingame.wakeLockOffTooltip
- [ ] ingame.leaveButton
- [ ] ingame.leaveConfirmTitle
- [ ] ingame.leaveConfirmBody
- [ ] ingame.leaveConfirmButton
- [ ] ingame.deadTitleLeft
- [ ] ingame.deadCauseLeft
- [ ] finish.killChainLeft
- [ ] finish.chatTitle
- [ ] finish.chatEmpty
- [ ] finish.chatHint
- [ ] finish.chatSendButton
- [ ] ingame.deadAlsoOut
- [ ] camera.permissionBlockedBody
- [ ] frame.cooldownReasonRejected
- [ ] frame.cooldownReasonTimeout
- [ ] ingame.leaveNetworkWarning

Everything not listed above predates this file and shipped without this
tracking — not a claim that it's been verified, just that its status
wasn't recorded. Only newly touched keys are required to go through this
list from here on.
