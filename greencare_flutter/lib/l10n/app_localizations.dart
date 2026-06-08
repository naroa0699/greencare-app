import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GreenCare'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myPlants.
  ///
  /// In en, this message translates to:
  /// **'My Plants'**
  String get myPlants;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @greenbot.
  ///
  /// In en, this message translates to:
  /// **'GreenBot'**
  String get greenbot;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search plants'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search aloe vera, monstera...'**
  String get searchHint;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlant;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to My Plants'**
  String get addToCollection;

  /// No description provided for @alreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already in your collection'**
  String get alreadyAdded;

  /// No description provided for @waterPlant.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterPlant;

  /// No description provided for @wateredToday.
  ///
  /// In en, this message translates to:
  /// **'Already watered today'**
  String get wateredToday;

  /// No description provided for @waterNow.
  ///
  /// In en, this message translates to:
  /// **'Water now!'**
  String get waterNow;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @deletePlant.
  ///
  /// In en, this message translates to:
  /// **'Delete plant'**
  String get deletePlant;

  /// No description provided for @deletePlantConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plant?'**
  String get deletePlantConfirm;

  /// No description provided for @newPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPost;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get postTitle;

  /// No description provided for @postContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get postContent;

  /// No description provided for @postTitleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: How do I care for my monstera?'**
  String get postTitleHint;

  /// No description provided for @postContentHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us more...'**
  String get postContentHint;

  /// No description provided for @viewThread.
  ///
  /// In en, this message translates to:
  /// **'View thread'**
  String get viewThread;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get replyHint;

  /// No description provided for @noPlants.
  ///
  /// In en, this message translates to:
  /// **'No plants yet'**
  String get noPlants;

  /// No description provided for @noPlantsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add one'**
  String get noPlantsHint;

  /// No description provided for @needsWaterToday.
  ///
  /// In en, this message translates to:
  /// **'Needs water today'**
  String get needsWaterToday;

  /// No description provided for @waterInDays.
  ///
  /// In en, this message translates to:
  /// **'Water in {days} days'**
  String waterInDays(int days);

  /// No description provided for @wateredPlant.
  ///
  /// In en, this message translates to:
  /// **'{name} watered 💧'**
  String wateredPlant(String name);

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'{days} day{plural} streak!'**
  String streak(int days, String plural);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @careCalendar.
  ///
  /// In en, this message translates to:
  /// **'Care calendar'**
  String get careCalendar;

  /// No description provided for @noWateringToday.
  ///
  /// In en, this message translates to:
  /// **'All good! No plants need water today.'**
  String get noWateringToday;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular searches'**
  String get popularSearches;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @searchTip.
  ///
  /// In en, this message translates to:
  /// **'Search by common or scientific name. If care data is unavailable, GreenBot will fill it in automatically.'**
  String get searchTip;

  /// No description provided for @watering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get watering;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @care.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get care;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String hello(String name);

  /// No description provided for @howAreYourPlants.
  ///
  /// In en, this message translates to:
  /// **'How are your plants today?'**
  String get howAreYourPlants;

  /// No description provided for @needWaterToday.
  ///
  /// In en, this message translates to:
  /// **'💧 Need water today'**
  String get needWaterToday;

  /// No description provided for @plantAdded.
  ///
  /// In en, this message translates to:
  /// **'Plant added to your collection! 🌿'**
  String get plantAdded;

  /// No description provided for @beFirstToPost.
  ///
  /// In en, this message translates to:
  /// **'Be the first to post! 🌿'**
  String get beFirstToPost;

  /// No description provided for @shareWithCommunity.
  ///
  /// In en, this message translates to:
  /// **'Share your plants and questions with the community'**
  String get shareWithCommunity;

  /// No description provided for @selectPost.
  ///
  /// In en, this message translates to:
  /// **'Select a post'**
  String get selectPost;

  /// No description provided for @orCreateNew.
  ///
  /// In en, this message translates to:
  /// **'or create a new one to get started'**
  String get orCreateNew;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get replies;

  /// No description provided for @beFirstToReply.
  ///
  /// In en, this message translates to:
  /// **'Be the first to reply'**
  String get beFirstToReply;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
