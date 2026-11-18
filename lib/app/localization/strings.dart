/// Textos de la App
abstract final class AppStrings {
  static const String appTitle = 'Pokédex';

  static const String online = 'En línea';
  static const String offline = 'Sin conexión';
  static const String checking = 'Comprobando conexión…';

  static const String refresh = 'Actualizar';
  static const String emptyCatalogTitle = 'Aún no hay Pokémon';
  static const String emptyCatalogMessage =
      'Conéctate a Internet para descargar el catálogo';
  static const String emptyCatalogOfflineMessage =
      'No hay conexión y todavía no se ha descargado ningún Pokémon';
  static const String errorTitle = 'No se pudo actualizar';
  static const String errorService =
      'El servicio no respondió. Se muestran los datos guardados';
  static const String errorOffline =
      'No hay conexión. Se muestran los datos guardados';
  static const String errorLocal = 'No se pudo leer la base de datos local';
  static const String retry = 'Reintentar';

  static const String darkMode = 'Modo Oscuro';
  static const String lightMode = 'Modo Claro';

  static const String gridView = "Vista de Grid";
  static const String listView = "Vista de Lista";

  static const String imageUnavailable = 'Imagen no disponible';
}
