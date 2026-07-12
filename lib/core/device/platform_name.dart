import 'dart:io';

/// The `platform` string the backend's players table expects: `'android'`
/// or `'ios'` (Framed is mobile-only, see IDEA.md "Tech used").
String currentPlatformName() => Platform.isIOS ? 'ios' : 'android';
