// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GreenCare';

  @override
  String get home => 'Home';

  @override
  String get myPlants => 'My Plants';

  @override
  String get calendar => 'Calendar';

  @override
  String get community => 'Community';

  @override
  String get greenbot => 'GreenBot';

  @override
  String get search => 'Search plants';

  @override
  String get searchHint => 'Search aloe vera, monstera...';

  @override
  String get addPlant => 'Add plant';

  @override
  String get addToCollection => 'Add to My Plants';

  @override
  String get alreadyAdded => 'Already in your collection';

  @override
  String get waterPlant => 'Water';

  @override
  String get wateredToday => 'Already watered today';

  @override
  String get waterNow => 'Water now!';

  @override
  String get undo => 'Undo';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get deletePlant => 'Delete plant';

  @override
  String get deletePlantConfirm => 'Are you sure you want to delete this plant?';

  @override
  String get newPost => 'New post';

  @override
  String get publish => 'Publish';

  @override
  String get postTitle => 'Title';

  @override
  String get postContent => 'Content';

  @override
  String get postTitleHint => 'E.g: How do I care for my monstera?';

  @override
  String get postContentHint => 'Tell us more...';

  @override
  String get viewThread => 'View thread';

  @override
  String get reply => 'Reply';

  @override
  String get replyHint => 'Write a reply...';

  @override
  String get noPlants => 'No plants yet';

  @override
  String get noPlantsHint => 'Tap + to add one';

  @override
  String get needsWaterToday => 'Needs water today';

  @override
  String waterInDays(int days) {
    return 'Water in $days days';
  }

  @override
  String wateredPlant(String name) {
    return '$name watered 💧';
  }

  @override
  String streak(int days, String plural) {
    return '$days day$plural streak!';
  }

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get theme => 'Color theme';

  @override
  String get language => 'Language';

  @override
  String get profile => 'My profile';

  @override
  String get logout => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get careCalendar => 'Care calendar';

  @override
  String get noWateringToday => 'All good! No plants need water today.';

  @override
  String get popularSearches => 'Popular searches';

  @override
  String get tip => 'Tip';

  @override
  String get searchTip => 'Search by common or scientific name. If care data is unavailable, GreenBot will fill it in automatically.';

  @override
  String get watering => 'Watering';

  @override
  String get light => 'Light';

  @override
  String get cycle => 'Cycle';

  @override
  String get description => 'Description';

  @override
  String get care => 'Care';

  @override
  String get achievements => 'Achievements';

  @override
  String hello(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get howAreYourPlants => 'How are your plants today?';

  @override
  String get needWaterToday => '💧 Need water today';

  @override
  String get plantAdded => 'Plant added to your collection! 🌿';

  @override
  String get beFirstToPost => 'Be the first to post! 🌿';

  @override
  String get shareWithCommunity => 'Share your plants and questions with the community';

  @override
  String get selectPost => 'Select a post';

  @override
  String get orCreateNew => 'or create a new one to get started';

  @override
  String get replies => 'Replies';

  @override
  String get beFirstToReply => 'Be the first to reply';
}
