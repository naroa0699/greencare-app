// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GreenCare';

  @override
  String get home => 'Accueil';

  @override
  String get myPlants => 'Mes plantes';

  @override
  String get calendar => 'Calendrier';

  @override
  String get community => 'Communauté';

  @override
  String get greenbot => 'GreenBot';

  @override
  String get search => 'Rechercher des plantes';

  @override
  String get searchHint => 'Rechercher aloe vera, monstera...';

  @override
  String get addPlant => 'Ajouter une plante';

  @override
  String get addToCollection => 'Ajouter à mes plantes';

  @override
  String get alreadyAdded => 'Déjà dans votre collection';

  @override
  String get waterPlant => 'Arroser';

  @override
  String get wateredToday => 'Déjà arrosée aujourd\'hui';

  @override
  String get waterNow => 'Arroser maintenant!';

  @override
  String get undo => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get deletePlant => 'Supprimer la plante';

  @override
  String get deletePlantConfirm => 'Voulez-vous vraiment supprimer cette plante?';

  @override
  String get newPost => 'Nouvelle publication';

  @override
  String get publish => 'Publier';

  @override
  String get postTitle => 'Titre';

  @override
  String get postContent => 'Contenu';

  @override
  String get postTitleHint => 'Ex: Comment entretenir mon monstera?';

  @override
  String get postContentHint => 'Dites-nous en plus...';

  @override
  String get viewThread => 'Voir le fil';

  @override
  String get reply => 'Réponse';

  @override
  String get replyHint => 'Écrire une réponse...';

  @override
  String get noPlants => 'Pas encore de plantes';

  @override
  String get noPlantsHint => 'Appuyez sur + pour en ajouter une';

  @override
  String get needsWaterToday => 'A besoin d\'eau aujourd\'hui';

  @override
  String waterInDays(int days) {
    return 'Arroser dans $days jours';
  }

  @override
  String wateredPlant(String name) {
    return '$name arrosée 💧';
  }

  @override
  String streak(int days, String plural) {
    return '$days jour$plural de série!';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get theme => 'Thème de couleur';

  @override
  String get language => 'Langue';

  @override
  String get profile => 'Mon profil';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get careCalendar => 'Calendrier de soins';

  @override
  String get noWateringToday => 'Tout va bien! Aucune plante n\'a besoin d\'eau aujourd\'hui.';

  @override
  String get popularSearches => 'Recherches populaires';

  @override
  String get tip => 'Conseil';

  @override
  String get searchTip => 'Recherchez par nom commun ou scientifique. Si les données ne sont pas disponibles, GreenBot les complétera automatiquement.';

  @override
  String get watering => 'Arrosage';

  @override
  String get light => 'Lumière';

  @override
  String get cycle => 'Cycle';

  @override
  String get description => 'Description';

  @override
  String get care => 'Soins';

  @override
  String get achievements => 'Succès';

  @override
  String hello(String name) {
    return 'Bonjour, $name 👋';
  }

  @override
  String get howAreYourPlants => 'Comment vont vos plantes aujourd\'hui?';

  @override
  String get needWaterToday => '💧 Besoin d\'eau aujourd\'hui';

  @override
  String get plantAdded => 'Plante ajoutée à votre collection! 🌿';

  @override
  String get beFirstToPost => 'Soyez le premier à publier! 🌿';

  @override
  String get shareWithCommunity => 'Partagez vos plantes et questions avec la communauté';

  @override
  String get selectPost => 'Sélectionnez une publication';

  @override
  String get orCreateNew => 'ou créez-en une nouvelle pour commencer';

  @override
  String get replies => 'Réponses';

  @override
  String get beFirstToReply => 'Soyez le premier à répondre';
}
