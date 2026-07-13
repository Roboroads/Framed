///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$app$en app = Translations$app$en._(_root);
	late final Translations$bootstrap$en bootstrap = Translations$bootstrap$en._(_root);
	late final Translations$location$en location = Translations$location$en._(_root);
	late final Translations$locationGate$en locationGate = Translations$locationGate$en._(_root);
	late final Translations$home$en home = Translations$home$en._(_root);
	late final Translations$goodToKnow$en goodToKnow = Translations$goodToKnow$en._(_root);
	late final Translations$hostSetup$en hostSetup = Translations$hostSetup$en._(_root);
	late final Translations$preJoin$en preJoin = Translations$preJoin$en._(_root);
	late final Translations$lobby$en lobby = Translations$lobby$en._(_root);
	late final Translations$ingame$en ingame = Translations$ingame$en._(_root);
	late final Translations$scan$en scan = Translations$scan$en._(_root);
	late final Translations$frame$en frame = Translations$frame$en._(_root);
	late final Translations$camera$en camera = Translations$camera$en._(_root);
	late final Translations$permissionRationale$en permissionRationale = Translations$permissionRationale$en._(_root);
	late final Translations$join$en join = Translations$join$en._(_root);
}

// Path: app
class Translations$app$en {
	Translations$app$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Framed'
	String get title => 'Framed';
}

// Path: bootstrap
class Translations$bootstrap$en {
	Translations$bootstrap$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Couldn't reach the server. Check your connection and try again.'
	String get errorGeneric => 'Couldn\'t reach the server. Check your connection and try again.';

	/// en: 'Try again'
	String get retry => 'Try again';
}

// Path: location
class Translations$location$en {
	Translations$location$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Framed is running'
	String get notificationTitle => 'Framed is running';

	/// en: 'Sharing your location for the current game.'
	String get notificationText => 'Sharing your location for the current game.';
}

// Path: locationGate
class Translations$locationGate$en {
	Translations$locationGate$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Location access'
	String get explainerTitle => 'Location access';

	/// en: 'Framed needs your location in the background, even with the screen locked, to point your target's compass and enforce the play area. Only your last-known location is ever stored — deleted when the game ends.'
	String get explainerBody => 'Framed needs your location in the background, even with the screen locked, to point your target\'s compass and enforce the play area. Only your last-known location is ever stored — deleted when the game ends.';

	/// en: 'Continue'
	String get continueButton => 'Continue';

	/// en: 'Location is off'
	String get blockedTitle => 'Location is off';

	/// en: 'Framed can't track your location. Turn it on in Settings, then come back — you don't need to restart the app.'
	String get blockedBody => 'Framed can\'t track your location. Turn it on in Settings, then come back — you don\'t need to restart the app.';

	/// en: 'Open settings'
	String get openSettings => 'Open settings';
}

// Path: home
class Translations$home$en {
	Translations$home$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Join game'
	String get joinGame => 'Join game';

	/// en: 'Host game'
	String get hostGame => 'Host game';

	/// en: 'Good to know'
	String get goodToKnowButton => 'Good to know';

	/// en: 'This game trusts the group. We don't detect GPS spoofing or modified clients — just play fair.'
	String get playFairDisclaimer => 'This game trusts the group. We don\'t detect GPS spoofing or modified clients — just play fair.';
}

// Path: goodToKnow
class Translations$goodToKnow$en {
	Translations$goodToKnow$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Good to know'
	String get title => 'Good to know';

	/// en: 'Play fair'
	String get fairPlayTitle => 'Play fair';

	/// en: 'Your privacy'
	String get privacyTitle => 'Your privacy';

	/// en: 'No analytics, no ads, no accounts — nobody's tracking you. Your name, selfie, frame photos, and dead chat are encrypted on your phone before they're ever sent, with a key generated on the host's device and shared only through the join QR code — it never reaches the server. Location is the one exception: the server reads it in plain text because it has to, to enforce the play area, drive the compass, and check who's died. Only your last-known location is ever stored, never a movement trail. Everything is deleted when the game ends, or after 24 hours, whichever comes first.'
	String get privacyBody => 'No analytics, no ads, no accounts — nobody\'s tracking you. Your name, selfie, frame photos, and dead chat are encrypted on your phone before they\'re ever sent, with a key generated on the host\'s device and shared only through the join QR code — it never reaches the server. Location is the one exception: the server reads it in plain text because it has to, to enforce the play area, drive the compass, and check who\'s died. Only your last-known location is ever stored, never a movement trail. Everything is deleted when the game ends, or after 24 hours, whichever comes first.';

	/// en: 'How we make money'
	String get moneyTitle => 'How we make money';

	/// en: 'Right now, nothing — there's no monetization. The server this game runs on is self-hosted and paid for out of pocket, for the love of the game.'
	String get moneyBody => 'Right now, nothing — there\'s no monetization. The server this game runs on is self-hosted and paid for out of pocket, for the love of the game.';

	/// en: 'About this app'
	String get aiTitle => 'About this app';

	/// en: 'This app is mostly built with AI assistance. It's built by a developer with over 16 years of professional software experience, who has read, reviewed, and been present for every step of the code that ended up here.'
	String get aiBody => 'This app is mostly built with AI assistance. It\'s built by a developer with over 16 years of professional software experience, who has read, reviewed, and been present for every step of the code that ended up here.';

	/// en: 'New to Framed?'
	String get beginnerTipsTitle => 'New to Framed?';

	/// en: 'Once the game starts you get a dispersal countdown — nobody can be framed until it ends, so actually spread out. After that, everyone gets a compass pulse on the same schedule: an arrow and distance to your target, refreshed at a fixed interval and gone again after a few seconds — if people around you glance at their phones at the same moment, that's the tell. Stay inside the host's play area: leave it too long and your assassin sees your exact location, stay out or go dark long enough and you die automatically. To make a kill, photograph your target in the app — the other players vote on whether it's really them. A majority yes ends their game; a failed vote costs you a cooldown before you can try again.'
	String get beginnerTipsBody => 'Once the game starts you get a dispersal countdown — nobody can be framed until it ends, so actually spread out. After that, everyone gets a compass pulse on the same schedule: an arrow and distance to your target, refreshed at a fixed interval and gone again after a few seconds — if people around you glance at their phones at the same moment, that\'s the tell. Stay inside the host\'s play area: leave it too long and your assassin sees your exact location, stay out or go dark long enough and you die automatically. To make a kill, photograph your target in the app — the other players vote on whether it\'s really them. A majority yes ends their game; a failed vote costs you a cooldown before you can try again.';
}

// Path: hostSetup
class Translations$hostSetup$en {
	Translations$hostSetup$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Host a game'
	String get title => 'Host a game';

	/// en: 'Game mode'
	String get modeSectionTitle => 'Game mode';

	/// en: 'Most frames wins'
	String get modeMostFrames => 'Most frames wins';

	/// en: 'Whoever has the most confirmed frames when the game ends wins, even if they've been framed themselves.'
	String get modeMostFramesDescription => 'Whoever has the most confirmed frames when the game ends wins, even if they\'ve been framed themselves.';

	/// en: 'Last man standing'
	String get modeLastManStanding => 'Last man standing';

	/// en: 'The last player alive wins.'
	String get modeLastManStandingDescription => 'The last player alive wins.';

	/// en: 'Play area'
	String get geofenceSectionTitle => 'Play area';

	/// en: 'The circle everyone has to stay inside. The server enforces this — leaving it for too long counts as breaking a rule.'
	String get geofenceInfo => 'The circle everyone has to stay inside. The server enforces this — leaving it for too long counts as breaking a rule.';

	/// en: '$radius m radius'
	String geofenceRadiusLabel({required Object radius}) => '${radius} m radius';

	/// en: 'Timing'
	String get timingSectionTitle => 'Timing';

	/// en: 'Dispersal time (minutes)'
	String get disperseMinutes => 'Dispersal time (minutes)';

	/// en: 'Countdown after the game starts before targets are assigned. Nobody can frame anyone until it ends.'
	String get disperseMinutesInfo => 'Countdown after the game starts before targets are assigned. Nobody can frame anyone until it ends.';

	/// en: 'Soft punishment after (minutes)'
	String get softPunishmentMinutes => 'Soft punishment after (minutes)';

	/// en: 'How long you can break a rule — leaving the play area, a stale location — before your assassin sees your exact position on their map.'
	String get softPunishmentMinutesInfo => 'How long you can break a rule — leaving the play area, a stale location — before your assassin sees your exact position on their map.';

	/// en: 'Hard punishment after (minutes)'
	String get hardPunishmentMinutes => 'Hard punishment after (minutes)';

	/// en: 'How long before breaking a rule kills you outright. The death screen shows it as "broke a game rule for too long".'
	String get hardPunishmentMinutesInfo => 'How long before breaking a rule kills you outright. The death screen shows it as "broke a game rule for too long".';

	/// en: 'Compass pulse interval (minutes)'
	String get compassUpdateIntervalMinutes => 'Compass pulse interval (minutes)';

	/// en: 'How often the compass pulse fires. Every alive player gets an arrow and distance to their target at the same moment.'
	String get compassUpdateIntervalMinutesInfo => 'How often the compass pulse fires. Every alive player gets an arrow and distance to their target at the same moment.';

	/// en: 'Compass visible for (seconds)'
	String get compassViewSeconds => 'Compass visible for (seconds)';

	/// en: 'How many seconds that arrow and distance stay on screen before disappearing again.'
	String get compassViewSecondsInfo => 'How many seconds that arrow and distance stay on screen before disappearing again.';

	/// en: 'Vote timeout (minutes)'
	String get voteTimeoutMinutes => 'Vote timeout (minutes)';

	/// en: 'How long a frame photo stays open for judges to vote on before it resolves on whatever votes were actually cast.'
	String get voteTimeoutMinutesInfo => 'How long a frame photo stays open for judges to vote on before it resolves on whatever votes were actually cast.';

	/// en: 'Frame cooldown (minutes)'
	String get frameCooldownMinutes => 'Frame cooldown (minutes)';

	/// en: 'How long an assassin waits after a failed frame vote before they can submit another photo.'
	String get frameCooldownMinutesInfo => 'How long an assassin waits after a failed frame vote before they can submit another photo.';

	/// en: 'Create game'
	String get createGame => 'Create game';

	/// en: 'Something in the settings doesn't look right — check the values and try again.'
	String get errorBadSettings => 'Something in the settings doesn\'t look right — check the values and try again.';

	/// en: 'Couldn't create the game. Check your connection and try again.'
	String get errorGeneric => 'Couldn\'t create the game. Check your connection and try again.';
}

// Path: preJoin
class Translations$preJoin$en {
	Translations$preJoin$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You're playing too'
	String get title => 'You\'re playing too';

	/// en: 'Your name'
	String get nameLabel => 'Your name';

	/// en: 'We collect your name, reference selfie, live location, frame photos, and push notifications for this game only. Everything is deleted when the game ends, or after 24 hours at the latest. Joining means you agree, and that you'll play safe: watch for traffic, don't trespass, no physical contact, don't photograph bystanders up close, and respect any areas the host declares off-limits.'
	String get consentNotice => 'We collect your name, reference selfie, live location, frame photos, and push notifications for this game only. Everything is deleted when the game ends, or after 24 hours at the latest. Joining means you agree, and that you\'ll play safe: watch for traffic, don\'t trespass, no physical contact, don\'t photograph bystanders up close, and respect any areas the host declares off-limits.';

	/// en: 'Judges compare this to every frame you're in — make sure your face is clearly visible.'
	String get selfieHint => 'Judges compare this to every frame you\'re in — make sure your face is clearly visible.';

	/// en: 'Take reference selfie'
	String get takeSelfie => 'Take reference selfie';

	/// en: 'Retake selfie'
	String get retakeSelfie => 'Retake selfie';
}

// Path: lobby
class Translations$lobby$en {
	Translations$lobby$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lobby'
	String get title => 'Lobby';

	/// en: 'Scan to join'
	String get scanToJoin => 'Scan to join';

	/// en: '$ready/$total ready'
	String readyCount({required Object ready, required Object total}) => '${ready}/${total} ready';

	/// en: 'Host'
	String get hostBadge => 'Host';

	/// en: 'Ready'
	String get readyBadge => 'Ready';

	/// en: 'Not ready yet'
	String get notReadyBadge => 'Not ready yet';

	/// en: 'Start game'
	String get startButton => 'Start game';

	/// en: 'Need at least 3 ready players'
	String get startTooFewPlayers => 'Need at least 3 ready players';

	/// en: 'Waiting for the host to start…'
	String get waitingForHost => 'Waiting for the host to start…';

	/// en: 'Change mode'
	String get changeMode => 'Change mode';

	/// en: 'Something went wrong. Check your connection and try again.'
	String get errorGeneric => 'Something went wrong. Check your connection and try again.';
}

// Path: ingame
class Translations$ingame$en {
	Translations$ingame$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spread out'
	String get disperseTitle => 'Spread out';

	/// en: 'You'll get your target when this hits zero.'
	String get disperseInstruction => 'You\'ll get your target when this hits zero.';

	/// en: 'Your target'
	String get targetCardTitle => 'Your target';

	/// en: 'Couldn't load your target. Try reopening the app.'
	String get errorTargetLoad => 'Couldn\'t load your target. Try reopening the app.';

	/// en: 'You're outside the play area — go back.'
	String get warningGeofence => 'You\'re outside the play area — go back.';

	/// en: 'We're not receiving your location. Check GPS, signal, and battery saver.'
	String get warningStale => 'We\'re not receiving your location. Check GPS, signal, and battery saver.';

	/// en: 'You die in $time'
	String warningDeadline({required Object time}) => 'You die in ${time}';

	/// en: 'No compass while breaking rules'
	String get compassNoPulseWarning => 'No compass while breaking rules';

	/// en: 'Next pulse soon'
	String get compassNoPulseIdle => 'Next pulse soon';

	/// en: '$distance m'
	String compassDistanceMeters({required Object distance}) => '${distance} m';

	/// en: '$direction, $distance m'
	String compassFallback({required Object direction, required Object distance}) => '${direction}, ${distance} m';

	/// en: 'Your target left the play area — this is where they are'
	String get targetLocationTitle => 'Your target left the play area — this is where they are';

	/// en: 'Is this $name?'
	String judgingTitle({required Object name}) => 'Is this ${name}?';

	/// en: 'Skip this and you'll miss your next compass pulse.'
	String get judgingNudge => 'Skip this and you\'ll miss your next compass pulse.';

	/// en: 'Couldn't load this frame.'
	String get judgingLoadError => 'Couldn\'t load this frame.';

	/// en: 'Retry'
	String get judgingRetry => 'Retry';

	/// en: 'Yes'
	String get judgingYes => 'Yes';

	/// en: 'No'
	String get judgingNo => 'No';
}

// Path: scan
class Translations$scan$en {
	Translations$scan$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan to join'
	String get title => 'Scan to join';

	/// en: 'That's not a valid Framed code — keep scanning.'
	String get invalidCode => 'That\'s not a valid Framed code — keep scanning.';
}

// Path: frame
class Translations$frame$en {
	Translations$frame$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Frame'
	String get button => 'Frame';

	/// en: 'Waiting for verdict'
	String get waiting => 'Waiting for verdict';

	/// en: 'Cooldown $time'
	String cooldown({required Object time}) => 'Cooldown ${time}';

	/// en: 'Confirm frame'
	String get confirmTitle => 'Confirm frame';

	/// en: 'Retake'
	String get retake => 'Retake';

	/// en: 'Submit'
	String get submit => 'Submit';

	/// en: 'Still cooling down from your last frame.'
	String get errorOnCooldown => 'Still cooling down from your last frame.';

	/// en: 'You already have a frame awaiting judgment.'
	String get errorAlreadyPending => 'You already have a frame awaiting judgment.';

	/// en: 'You can't frame anyone right now.'
	String get errorWrongStatus => 'You can\'t frame anyone right now.';

	/// en: 'Couldn't submit that frame. Check your connection and try again.'
	String get errorGeneric => 'Couldn\'t submit that frame. Check your connection and try again.';
}

// Path: camera
class Translations$camera$en {
	Translations$camera$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Framed needs camera access for this. Grant it, then try again.'
	String get permissionDeniedBody => 'Framed needs camera access for this. Grant it, then try again.';

	/// en: 'Couldn't start the camera. Try again.'
	String get errorGeneric => 'Couldn\'t start the camera. Try again.';

	/// en: 'Try again'
	String get retry => 'Try again';
}

// Path: permissionRationale
class Translations$permissionRationale$en {
	Translations$permissionRationale$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Framed uses your location to point a compass arrow at your target and to enforce the play area the host set — the server needs this to run the game.'
	String get locationExplanation => 'Framed uses your location to point a compass arrow at your target and to enforce the play area the host set — the server needs this to run the game.';

	/// en: 'Framed needs your camera for your reference selfie, and later for the frame photos judges compare it against to confirm a kill.'
	String get cameraExplanation => 'Framed needs your camera for your reference selfie, and later for the frame photos judges compare it against to confirm a kill.';
}

// Path: join
class Translations$join$en {
	Translations$join$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Join game'
	String get joinButton => 'Join game';

	/// en: 'That name is taken in this lobby.'
	String get errorNameTaken => 'That name is taken in this lobby.';

	/// en: 'Couldn't join the game. Check your connection and try again.'
	String get errorGeneric => 'Couldn\'t join the game. Check your connection and try again.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'Framed',
			'bootstrap.errorGeneric' => 'Couldn\'t reach the server. Check your connection and try again.',
			'bootstrap.retry' => 'Try again',
			'location.notificationTitle' => 'Framed is running',
			'location.notificationText' => 'Sharing your location for the current game.',
			'locationGate.explainerTitle' => 'Location access',
			'locationGate.explainerBody' => 'Framed needs your location in the background, even with the screen locked, to point your target\'s compass and enforce the play area. Only your last-known location is ever stored — deleted when the game ends.',
			'locationGate.continueButton' => 'Continue',
			'locationGate.blockedTitle' => 'Location is off',
			'locationGate.blockedBody' => 'Framed can\'t track your location. Turn it on in Settings, then come back — you don\'t need to restart the app.',
			'locationGate.openSettings' => 'Open settings',
			'home.joinGame' => 'Join game',
			'home.hostGame' => 'Host game',
			'home.goodToKnowButton' => 'Good to know',
			'home.playFairDisclaimer' => 'This game trusts the group. We don\'t detect GPS spoofing or modified clients — just play fair.',
			'goodToKnow.title' => 'Good to know',
			'goodToKnow.fairPlayTitle' => 'Play fair',
			'goodToKnow.privacyTitle' => 'Your privacy',
			'goodToKnow.privacyBody' => 'No analytics, no ads, no accounts — nobody\'s tracking you. Your name, selfie, frame photos, and dead chat are encrypted on your phone before they\'re ever sent, with a key generated on the host\'s device and shared only through the join QR code — it never reaches the server. Location is the one exception: the server reads it in plain text because it has to, to enforce the play area, drive the compass, and check who\'s died. Only your last-known location is ever stored, never a movement trail. Everything is deleted when the game ends, or after 24 hours, whichever comes first.',
			'goodToKnow.moneyTitle' => 'How we make money',
			'goodToKnow.moneyBody' => 'Right now, nothing — there\'s no monetization. The server this game runs on is self-hosted and paid for out of pocket, for the love of the game.',
			'goodToKnow.aiTitle' => 'About this app',
			'goodToKnow.aiBody' => 'This app is mostly built with AI assistance. It\'s built by a developer with over 16 years of professional software experience, who has read, reviewed, and been present for every step of the code that ended up here.',
			'goodToKnow.beginnerTipsTitle' => 'New to Framed?',
			'goodToKnow.beginnerTipsBody' => 'Once the game starts you get a dispersal countdown — nobody can be framed until it ends, so actually spread out. After that, everyone gets a compass pulse on the same schedule: an arrow and distance to your target, refreshed at a fixed interval and gone again after a few seconds — if people around you glance at their phones at the same moment, that\'s the tell. Stay inside the host\'s play area: leave it too long and your assassin sees your exact location, stay out or go dark long enough and you die automatically. To make a kill, photograph your target in the app — the other players vote on whether it\'s really them. A majority yes ends their game; a failed vote costs you a cooldown before you can try again.',
			'hostSetup.title' => 'Host a game',
			'hostSetup.modeSectionTitle' => 'Game mode',
			'hostSetup.modeMostFrames' => 'Most frames wins',
			'hostSetup.modeMostFramesDescription' => 'Whoever has the most confirmed frames when the game ends wins, even if they\'ve been framed themselves.',
			'hostSetup.modeLastManStanding' => 'Last man standing',
			'hostSetup.modeLastManStandingDescription' => 'The last player alive wins.',
			'hostSetup.geofenceSectionTitle' => 'Play area',
			'hostSetup.geofenceInfo' => 'The circle everyone has to stay inside. The server enforces this — leaving it for too long counts as breaking a rule.',
			'hostSetup.geofenceRadiusLabel' => ({required Object radius}) => '${radius} m radius',
			'hostSetup.timingSectionTitle' => 'Timing',
			'hostSetup.disperseMinutes' => 'Dispersal time (minutes)',
			'hostSetup.disperseMinutesInfo' => 'Countdown after the game starts before targets are assigned. Nobody can frame anyone until it ends.',
			'hostSetup.softPunishmentMinutes' => 'Soft punishment after (minutes)',
			'hostSetup.softPunishmentMinutesInfo' => 'How long you can break a rule — leaving the play area, a stale location — before your assassin sees your exact position on their map.',
			'hostSetup.hardPunishmentMinutes' => 'Hard punishment after (minutes)',
			'hostSetup.hardPunishmentMinutesInfo' => 'How long before breaking a rule kills you outright. The death screen shows it as "broke a game rule for too long".',
			'hostSetup.compassUpdateIntervalMinutes' => 'Compass pulse interval (minutes)',
			'hostSetup.compassUpdateIntervalMinutesInfo' => 'How often the compass pulse fires. Every alive player gets an arrow and distance to their target at the same moment.',
			'hostSetup.compassViewSeconds' => 'Compass visible for (seconds)',
			'hostSetup.compassViewSecondsInfo' => 'How many seconds that arrow and distance stay on screen before disappearing again.',
			'hostSetup.voteTimeoutMinutes' => 'Vote timeout (minutes)',
			'hostSetup.voteTimeoutMinutesInfo' => 'How long a frame photo stays open for judges to vote on before it resolves on whatever votes were actually cast.',
			'hostSetup.frameCooldownMinutes' => 'Frame cooldown (minutes)',
			'hostSetup.frameCooldownMinutesInfo' => 'How long an assassin waits after a failed frame vote before they can submit another photo.',
			'hostSetup.createGame' => 'Create game',
			'hostSetup.errorBadSettings' => 'Something in the settings doesn\'t look right — check the values and try again.',
			'hostSetup.errorGeneric' => 'Couldn\'t create the game. Check your connection and try again.',
			'preJoin.title' => 'You\'re playing too',
			'preJoin.nameLabel' => 'Your name',
			'preJoin.consentNotice' => 'We collect your name, reference selfie, live location, frame photos, and push notifications for this game only. Everything is deleted when the game ends, or after 24 hours at the latest. Joining means you agree, and that you\'ll play safe: watch for traffic, don\'t trespass, no physical contact, don\'t photograph bystanders up close, and respect any areas the host declares off-limits.',
			'preJoin.selfieHint' => 'Judges compare this to every frame you\'re in — make sure your face is clearly visible.',
			'preJoin.takeSelfie' => 'Take reference selfie',
			'preJoin.retakeSelfie' => 'Retake selfie',
			'lobby.title' => 'Lobby',
			'lobby.scanToJoin' => 'Scan to join',
			'lobby.readyCount' => ({required Object ready, required Object total}) => '${ready}/${total} ready',
			'lobby.hostBadge' => 'Host',
			'lobby.readyBadge' => 'Ready',
			'lobby.notReadyBadge' => 'Not ready yet',
			'lobby.startButton' => 'Start game',
			'lobby.startTooFewPlayers' => 'Need at least 3 ready players',
			'lobby.waitingForHost' => 'Waiting for the host to start…',
			'lobby.changeMode' => 'Change mode',
			'lobby.errorGeneric' => 'Something went wrong. Check your connection and try again.',
			'ingame.disperseTitle' => 'Spread out',
			'ingame.disperseInstruction' => 'You\'ll get your target when this hits zero.',
			'ingame.targetCardTitle' => 'Your target',
			'ingame.errorTargetLoad' => 'Couldn\'t load your target. Try reopening the app.',
			'ingame.warningGeofence' => 'You\'re outside the play area — go back.',
			'ingame.warningStale' => 'We\'re not receiving your location. Check GPS, signal, and battery saver.',
			'ingame.warningDeadline' => ({required Object time}) => 'You die in ${time}',
			'ingame.compassNoPulseWarning' => 'No compass while breaking rules',
			'ingame.compassNoPulseIdle' => 'Next pulse soon',
			'ingame.compassDistanceMeters' => ({required Object distance}) => '${distance} m',
			'ingame.compassFallback' => ({required Object direction, required Object distance}) => '${direction}, ${distance} m',
			'ingame.targetLocationTitle' => 'Your target left the play area — this is where they are',
			'ingame.judgingTitle' => ({required Object name}) => 'Is this ${name}?',
			'ingame.judgingNudge' => 'Skip this and you\'ll miss your next compass pulse.',
			'ingame.judgingLoadError' => 'Couldn\'t load this frame.',
			'ingame.judgingRetry' => 'Retry',
			'ingame.judgingYes' => 'Yes',
			'ingame.judgingNo' => 'No',
			'scan.title' => 'Scan to join',
			'scan.invalidCode' => 'That\'s not a valid Framed code — keep scanning.',
			'frame.button' => 'Frame',
			'frame.waiting' => 'Waiting for verdict',
			'frame.cooldown' => ({required Object time}) => 'Cooldown ${time}',
			'frame.confirmTitle' => 'Confirm frame',
			'frame.retake' => 'Retake',
			'frame.submit' => 'Submit',
			'frame.errorOnCooldown' => 'Still cooling down from your last frame.',
			'frame.errorAlreadyPending' => 'You already have a frame awaiting judgment.',
			'frame.errorWrongStatus' => 'You can\'t frame anyone right now.',
			'frame.errorGeneric' => 'Couldn\'t submit that frame. Check your connection and try again.',
			'camera.permissionDeniedBody' => 'Framed needs camera access for this. Grant it, then try again.',
			'camera.errorGeneric' => 'Couldn\'t start the camera. Try again.',
			'camera.retry' => 'Try again',
			'permissionRationale.ok' => 'OK',
			'permissionRationale.locationExplanation' => 'Framed uses your location to point a compass arrow at your target and to enforce the play area the host set — the server needs this to run the game.',
			'permissionRationale.cameraExplanation' => 'Framed needs your camera for your reference selfie, and later for the frame photos judges compare it against to confirm a kill.',
			'join.joinButton' => 'Join game',
			'join.errorNameTaken' => 'That name is taken in this lobby.',
			'join.errorGeneric' => 'Couldn\'t join the game. Check your connection and try again.',
			_ => null,
		};
	}
}
