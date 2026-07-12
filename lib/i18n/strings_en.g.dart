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
	late final Translations$home$en home = Translations$home$en._(_root);
	late final Translations$hostSetup$en hostSetup = Translations$hostSetup$en._(_root);
	late final Translations$preJoin$en preJoin = Translations$preJoin$en._(_root);
	late final Translations$lobby$en lobby = Translations$lobby$en._(_root);
}

// Path: app
class Translations$app$en {
	Translations$app$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Framed'
	String get title => 'Framed';
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

	/// en: 'This game trusts the group. We don't detect GPS spoofing or modified clients — just play fair.'
	String get playFairDisclaimer => 'This game trusts the group. We don\'t detect GPS spoofing or modified clients — just play fair.';
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

	/// en: '$radius m radius'
	String geofenceRadiusLabel({required Object radius}) => '${radius} m radius';

	/// en: 'Timing'
	String get timingSectionTitle => 'Timing';

	/// en: 'Dispersal time (minutes)'
	String get disperseMinutes => 'Dispersal time (minutes)';

	/// en: 'Soft punishment after (minutes)'
	String get softPunishmentMinutes => 'Soft punishment after (minutes)';

	/// en: 'Hard punishment after (minutes)'
	String get hardPunishmentMinutes => 'Hard punishment after (minutes)';

	/// en: 'Compass pulse interval (minutes)'
	String get compassUpdateIntervalMinutes => 'Compass pulse interval (minutes)';

	/// en: 'Compass visible for (seconds)'
	String get compassViewSeconds => 'Compass visible for (seconds)';

	/// en: 'Vote timeout (minutes)'
	String get voteTimeoutMinutes => 'Vote timeout (minutes)';

	/// en: 'Frame cooldown (minutes)'
	String get frameCooldownMinutes => 'Frame cooldown (minutes)';

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

	/// en: 'We collect your name and a reference selfie for this game only. Everything is deleted when the game ends, or after 24 hours at the latest. Taking the selfie means you agree.'
	String get consentNotice => 'We collect your name and a reference selfie for this game only. Everything is deleted when the game ends, or after 24 hours at the latest. Taking the selfie means you agree.';

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
			'home.joinGame' => 'Join game',
			'home.hostGame' => 'Host game',
			'home.playFairDisclaimer' => 'This game trusts the group. We don\'t detect GPS spoofing or modified clients — just play fair.',
			'hostSetup.title' => 'Host a game',
			'hostSetup.modeSectionTitle' => 'Game mode',
			'hostSetup.modeMostFrames' => 'Most frames wins',
			'hostSetup.modeMostFramesDescription' => 'Whoever has the most confirmed frames when the game ends wins, even if they\'ve been framed themselves.',
			'hostSetup.modeLastManStanding' => 'Last man standing',
			'hostSetup.modeLastManStandingDescription' => 'The last player alive wins.',
			'hostSetup.geofenceSectionTitle' => 'Play area',
			'hostSetup.geofenceRadiusLabel' => ({required Object radius}) => '${radius} m radius',
			'hostSetup.timingSectionTitle' => 'Timing',
			'hostSetup.disperseMinutes' => 'Dispersal time (minutes)',
			'hostSetup.softPunishmentMinutes' => 'Soft punishment after (minutes)',
			'hostSetup.hardPunishmentMinutes' => 'Hard punishment after (minutes)',
			'hostSetup.compassUpdateIntervalMinutes' => 'Compass pulse interval (minutes)',
			'hostSetup.compassViewSeconds' => 'Compass visible for (seconds)',
			'hostSetup.voteTimeoutMinutes' => 'Vote timeout (minutes)',
			'hostSetup.frameCooldownMinutes' => 'Frame cooldown (minutes)',
			'hostSetup.createGame' => 'Create game',
			'hostSetup.errorBadSettings' => 'Something in the settings doesn\'t look right — check the values and try again.',
			'hostSetup.errorGeneric' => 'Couldn\'t create the game. Check your connection and try again.',
			'preJoin.title' => 'You\'re playing too',
			'preJoin.nameLabel' => 'Your name',
			'preJoin.consentNotice' => 'We collect your name and a reference selfie for this game only. Everything is deleted when the game ends, or after 24 hours at the latest. Taking the selfie means you agree.',
			'preJoin.takeSelfie' => 'Take reference selfie',
			'preJoin.retakeSelfie' => 'Retake selfie',
			'lobby.title' => 'Lobby',
			'lobby.scanToJoin' => 'Scan to join',
			_ => null,
		};
	}
}
