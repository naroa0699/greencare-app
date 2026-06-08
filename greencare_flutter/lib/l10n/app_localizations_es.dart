// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GreenCare';

  @override
  String get home => 'Inicio';

  @override
  String get myPlants => 'Mis plantas';

  @override
  String get calendar => 'Calendario';

  @override
  String get community => 'Comunidad';

  @override
  String get greenbot => 'GreenBot';

  @override
  String get search => 'Buscar plantas';

  @override
  String get searchHint => 'Busca aloe vera, monstera...';

  @override
  String get addPlant => 'Añadir planta';

  @override
  String get addToCollection => 'Añadir a Mis Plantas';

  @override
  String get alreadyAdded => 'Ya añadida a tu colección';

  @override
  String get waterPlant => 'Regar';

  @override
  String get wateredToday => 'Ya regada hoy';

  @override
  String get waterNow => '¡Regar!';

  @override
  String get undo => 'Deshacer';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get deletePlant => 'Eliminar planta';

  @override
  String get deletePlantConfirm => '¿Seguro que quieres eliminar esta planta?';

  @override
  String get newPost => 'Nueva publicación';

  @override
  String get publish => 'Publicar';

  @override
  String get postTitle => 'Título';

  @override
  String get postContent => 'Contenido';

  @override
  String get postTitleHint => 'Ej: ¿Cómo cuido mi monstera?';

  @override
  String get postContentHint => 'Cuéntanos más...';

  @override
  String get viewThread => 'Ver hilo';

  @override
  String get reply => 'Respuesta';

  @override
  String get replyHint => 'Escribe una respuesta...';

  @override
  String get noPlants => 'Aún no tienes plantas';

  @override
  String get noPlantsHint => 'Pulsa + para añadir una';

  @override
  String get needsWaterToday => 'Necesita agua hoy';

  @override
  String waterInDays(int days) {
    return 'Regar en $days días';
  }

  @override
  String wateredPlant(String name) {
    return '$name regada 💧';
  }

  @override
  String streak(int days, String plural) {
    return '¡Llevas $days día$plural de racha!';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get theme => 'Tema de color';

  @override
  String get language => 'Idioma';

  @override
  String get profile => 'Mi perfil';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get careCalendar => 'Calendario de cuidados';

  @override
  String get noWateringToday => '¡Todo en orden! Ninguna planta necesita agua hoy.';

  @override
  String get popularSearches => 'Búsquedas populares';

  @override
  String get tip => 'Consejo';

  @override
  String get searchTip => 'Busca por nombre común o científico. Si los datos no están disponibles, GreenBot los completará automáticamente.';

  @override
  String get watering => 'Riego';

  @override
  String get light => 'Luz';

  @override
  String get cycle => 'Ciclo';

  @override
  String get description => 'Descripción';

  @override
  String get care => 'Cuidados';

  @override
  String get achievements => 'Logros';

  @override
  String hello(String name) {
    return 'Hola, $name 👋';
  }

  @override
  String get howAreYourPlants => '¿Cómo están tus plantas hoy?';

  @override
  String get needWaterToday => '💧 Necesitan agua hoy';

  @override
  String get plantAdded => '¡Planta añadida a tu colección! 🌿';

  @override
  String get beFirstToPost => '¡Sé el primero en publicar! 🌿';

  @override
  String get shareWithCommunity => 'Comparte tus plantas y dudas con la comunidad';

  @override
  String get selectPost => 'Selecciona una publicación';

  @override
  String get orCreateNew => 'o crea una nueva para empezar';

  @override
  String get replies => 'Respuestas';

  @override
  String get beFirstToReply => 'Sé el primero en responder';
}
