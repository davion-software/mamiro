// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mamiro';

  @override
  String get navToday => 'Hoy';

  @override
  String get navMeds => 'Medicinas';

  @override
  String get navHistory => 'Historial';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get storageUnavailable =>
      'El almacenamiento no está disponible por ahora.';

  @override
  String get storageCorrupt => 'No se pudieron leer los datos guardados.';

  @override
  String get storageConstraint => 'No se pudo guardar ese cambio.';

  @override
  String get storageNotFound => 'Ese elemento ya no está disponible.';

  @override
  String get todayUnavailable => 'Hoy no está disponible por ahora.';

  @override
  String get cabinetUnavailable => 'El botiquín no está disponible por ahora.';

  @override
  String get historyUnavailable => 'El historial no está disponible por ahora.';

  @override
  String get settingsUnavailable =>
      'Los ajustes no están disponibles por ahora.';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String todayNextOne(String name, String time) {
    return 'Próxima: $name a las $time';
  }

  @override
  String todayNextMany(int count, String time) {
    return 'Próxima: $count tomas a las $time';
  }

  @override
  String get todayAllDone => 'Todo hecho por hoy';

  @override
  String todayWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tomas pendientes',
      one: '1 toma pendiente',
    );
    return '$_temp0';
  }

  @override
  String get sectionDueNow => 'Ahora';

  @override
  String get sectionNext => 'Próxima';

  @override
  String get sectionLater => 'Más tarde';

  @override
  String get sectionDone => 'Hechas';

  @override
  String get sectionRefill => 'Reponer pronto';

  @override
  String get takeAction => 'Tomar';

  @override
  String takeAll(int count) {
    return 'Tomar todas ($count)';
  }

  @override
  String get skipAction => 'Omitir';

  @override
  String get takeEarly => 'Tomar ahora';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get statusMissed => 'Sin tomar';

  @override
  String statusSnoozedUntil(String time) {
    return 'Pospuesta hasta las $time';
  }

  @override
  String get statusTaken => 'Tomada';

  @override
  String get statusSkipped => 'Omitida';

  @override
  String get statusLater => 'Pendiente';

  @override
  String get statusDue => 'Ahora';

  @override
  String get statusSnoozed => 'Pospuesta';

  @override
  String doneTakenAt(String time) {
    return 'Tomada a las $time';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String pillsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count',
      one: 'Queda 1',
    );
    return '$_temp0';
  }

  @override
  String get refillSoonTag => 'reponer pronto';

  @override
  String get restock => 'Reponer';

  @override
  String restockTitle(String name) {
    return 'Reponer $name';
  }

  @override
  String get restockField => 'Pastillas añadidas';

  @override
  String get restockConfirm => 'Añadir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get emptyCabinetTitle => 'Tu botiquín está vacío.';

  @override
  String get emptyCabinetBody =>
      'Añade lo que tomas y Mamiro sonará en cada toma.';

  @override
  String get addMedication => 'Añadir medicamento';

  @override
  String get addShort => 'Añadir';

  @override
  String get nothingToday => 'Nada programado para hoy.';

  @override
  String get alarmDoseDue => 'Hora de tu toma';

  @override
  String alarmCounter(int index, int count) {
    return '$index de $count';
  }

  @override
  String get alarmTestLabel => 'Alarma de prueba';

  @override
  String get alarmOnTime => 'Justo a tiempo';

  @override
  String alarmLateMinutes(int minutes) {
    return 'Programada hace $minutes min';
  }

  @override
  String alarmLateHours(int hours, int minutes) {
    return 'Programada hace $hours h $minutes min';
  }

  @override
  String alarmAlsoDue(String names) {
    return 'También ahora: $names';
  }

  @override
  String alarmSnooze(int minutes) {
    return 'Posponer $minutes min';
  }

  @override
  String get snoozeShort => 'Posponer';

  @override
  String alarmNotificationTitle(String name) {
    return 'Hora de $name';
  }

  @override
  String get channelRingVibrate => 'Alarmas de tomas';

  @override
  String get channelRing => 'Alarmas de tomas (sin vibración)';

  @override
  String get channelVibrate => 'Alarmas de tomas (en silencio)';

  @override
  String get channelQuiet => 'Alarmas de tomas (en silencio, sin vibración)';

  @override
  String get channelDescription =>
      'Suena a la hora de cada toma hasta que la tomas, pospones u omites';

  @override
  String get testNotificationBody =>
      'Así sonará Mamiro a la hora de cada toma.';

  @override
  String get cabinetTitle => 'Botiquín';

  @override
  String get cabinetSubtitle => 'Qué tomas, cuándo y qué días.';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get editorAddTitle => 'Nuevo medicamento';

  @override
  String get editorEditTitle => 'Editar medicamento';

  @override
  String get fieldName => 'Nombre';

  @override
  String get nameRequired => 'Ponle un nombre';

  @override
  String get fieldDosage => 'Dosis';

  @override
  String get dosageHint => '10 mg';

  @override
  String get dosageRequired => 'Añade la dosis';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get notesHint => 'con el desayuno';

  @override
  String get sectionTimes => 'Horas';

  @override
  String get addTime => 'Añadir hora';

  @override
  String get timeHelp => 'Toca una hora para cambiarla.';

  @override
  String get timesRequired => 'Añade al menos una hora';

  @override
  String get sectionDays => 'Días';

  @override
  String get daysSpecific => 'Días concretos';

  @override
  String get daysRequired => 'Elige al menos un día';

  @override
  String get sectionInventory => 'Existencias';

  @override
  String get trackPills => 'Contar pastillas restantes';

  @override
  String get trackPillsHelp =>
      'Se descuenta una pastilla cada vez que registras una toma.';

  @override
  String get pillCount => 'Pastillas disponibles';

  @override
  String get countRequired => 'Indica cuántas tienes';

  @override
  String get thresholdField => 'Avisarme para reponer al llegar a';

  @override
  String get thresholdRequired => 'Indica el nivel de aviso';

  @override
  String get wholeNumber => 'Introduce un número entero';

  @override
  String get thresholdWarning =>
      'Ya estás en el nivel de reposición o por debajo.';

  @override
  String get sectionAppearance => 'Aspecto';

  @override
  String get shapeCapsule => 'Cápsula';

  @override
  String get shapeTablet => 'Comprimido';

  @override
  String get shapeSoftgel => 'Perla';

  @override
  String get colorSage => 'Salvia';

  @override
  String get colorMoss => 'Musgo';

  @override
  String get colorTerracotta => 'Terracota';

  @override
  String get colorClay => 'Arcilla';

  @override
  String get colorSand => 'Arena';

  @override
  String get colorSlate => 'Pizarra';

  @override
  String get colorInk => 'Tinta';

  @override
  String get colorBlush => 'Rosa';

  @override
  String get save => 'Guardar';

  @override
  String get deleteMedication => 'Eliminar medicamento';

  @override
  String get deleteTitle => '¿Quitar del botiquín?';

  @override
  String deleteBody(String name) {
    return '$name desaparecerá de Hoy y sus alarmas dejarán de sonar. El historial se conserva.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get historyTitle => 'Últimos 7 días';

  @override
  String historyTaken(int taken, int total) {
    return '$taken de $total tomas cumplidas';
  }

  @override
  String get historyNoData => 'Aún no hay tomas que contar.';

  @override
  String get streakNone => 'Aún sin racha';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días completos seguidos',
      one: '1 día completo seguido',
    );
    return '$_temp0';
  }

  @override
  String get sectionDayByDay => 'Día a día';

  @override
  String get legendComplete => 'Todo tomado';

  @override
  String get legendMixed => 'Sin tomar u omitidas';

  @override
  String get legendPending => 'En curso';

  @override
  String get legendEmpty => 'Sin tomas';

  @override
  String get dayHint => 'Toca un día para ver sus tomas.';

  @override
  String get daySheetEmpty => 'No había tomas programadas.';

  @override
  String get sectionLog => 'Registro reciente';

  @override
  String get logEmpty =>
      'Aquí aparecerán las tomas, omisiones y aplazamientos.';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String logSkippedAt(String time) {
    return 'Omitida a las $time';
  }

  @override
  String logSnoozedAt(String time) {
    return 'Pospuesta a las $time';
  }

  @override
  String logScheduled(String time) {
    return 'programada a las $time';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsIntro =>
      'Las alarmas suenan a la hora de cada toma, aunque Mamiro esté cerrada.';

  @override
  String get sectionAccess => 'Permisos de alarma';

  @override
  String get accessNotifications => 'Notificaciones';

  @override
  String get accessNotificationsHelp =>
      'Necesarias para sonar con la app cerrada';

  @override
  String get accessExact => 'Hora exacta';

  @override
  String get accessExactHelp => 'Sonar en el minuto exacto';

  @override
  String get accessFullScreen => 'Alarmas a pantalla completa';

  @override
  String get accessFullScreenHelp =>
      'Aparecen sobre la pantalla de bloqueo. Android no permite consultarlo: compruébalo en los ajustes del sistema.';

  @override
  String get allow => 'Permitir';

  @override
  String get open => 'Abrir';

  @override
  String get allowed => 'Permitido';

  @override
  String get sectionAlarm => 'Alarma';

  @override
  String get sound => 'Sonido';

  @override
  String get soundHelp => 'Tono de alarma a la hora de la toma';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationHelp => 'Vibrar con la alarma';

  @override
  String get banners => 'Aviso de pendientes';

  @override
  String get bannersHelp => 'Muestra las tomas pendientes arriba en Hoy';

  @override
  String get sectionSnooze => 'Duración del aplazamiento';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get sectionTest => 'Probar';

  @override
  String get testNow => 'Probar alarma ahora';

  @override
  String get testClosed => 'Probar con la app cerrada';

  @override
  String get testClosedHelp =>
      'Sonará en 10 segundos. Cierra Mamiro para comprobarlo.';

  @override
  String testScheduled(String time) {
    return 'Alarma de prueba a las $time';
  }

  @override
  String get sectionAdvanced => 'Avanzado';

  @override
  String get restoreDemo => 'Restaurar botiquín de ejemplo';

  @override
  String get clearAll => 'Borrar todos los datos';

  @override
  String get demoRestored => 'Botiquín de ejemplo restaurado';

  @override
  String get cleared => 'Datos borrados';

  @override
  String get clearTitle => '¿Borrar este dispositivo?';

  @override
  String get clearBody =>
      'Se eliminarán todos los medicamentos y registros de este teléfono. No se puede deshacer.';

  @override
  String get clearConfirm => 'Borrar todo';

  @override
  String get notFoundTitle => 'No encontramos esa pantalla.';

  @override
  String get notFoundBody => 'Puede que haya cambiado de sitio. Vuelve a Hoy.';

  @override
  String get goToday => 'Ir a Hoy';

  @override
  String get demoVitaminD3 => 'Vitamina D3';

  @override
  String get demoMagnesium => 'Magnesio';

  @override
  String get demoWithBreakfast => 'con el desayuno';

  @override
  String get demoSameTimes => 'siempre a la misma hora';

  @override
  String get demoBeforeBed => 'antes de dormir';

  @override
  String get sectionTheme => 'Tema';

  @override
  String get themeNightApricot => 'Azul noche y albaricoque';

  @override
  String get themeCobaltPeach => 'Cobalto y melocotón';

  @override
  String get themeTealCoral => 'Petróleo y coral';

  @override
  String get themePlumPeach => 'Ciruela y melocotón';

  @override
  String get themeDefault => 'Predeterminado';

  @override
  String undoTaken(String name) {
    return 'Tomada: $name';
  }

  @override
  String undoSkipped(String name) {
    return 'Omitida: $name';
  }

  @override
  String undoRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tomas registradas',
      one: '1 toma registrada',
    );
    return '$_temp0';
  }

  @override
  String lateTakeTitleOne(String name) {
    return '¿Cuándo tomaste $name?';
  }

  @override
  String lateTakeTitleMany(int count) {
    return '¿Cuándo tomaste estas $count tomas?';
  }

  @override
  String lateTakeNow(String time) {
    return 'Ahora ($time)';
  }

  @override
  String lateTakeOnTime(String time) {
    return 'A su hora ($time)';
  }

  @override
  String get lateTakeOther => 'Otra hora…';

  @override
  String lateTakeAdjusted(String time) {
    return 'Ajustada a las $time: debe estar entre la hora programada y ahora.';
  }

  @override
  String get accessBannerNotifications =>
      'Las alarmas no sonarán con la app cerrada';

  @override
  String get accessBannerExact => 'Las alarmas pueden sonar con retraso';

  @override
  String get accessBannerEnable => 'Activar';

  @override
  String get primerTitle => 'Para que Mamiro suene a tiempo';

  @override
  String get primerClosedApp =>
      'Las alarmas suenan a la hora de cada toma, aunque la app esté cerrada.';

  @override
  String get primerActions =>
      'Puedes tomar, posponer u omitir desde la propia notificación.';

  @override
  String get primerLater => 'Puedes cambiarlo cuando quieras en Ajustes.';

  @override
  String get primerAllow => 'Permitir alarmas';

  @override
  String get primerNotNow => 'Ahora no';

  @override
  String earlyTakeTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Tomar $count tomas ahora?',
      one: '¿Tomar $name ahora?',
    );
    return '$_temp0';
  }

  @override
  String earlyTakeBody(String time) {
    return 'Está programada a las $time.';
  }
}
