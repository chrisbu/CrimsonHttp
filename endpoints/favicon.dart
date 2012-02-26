/// Handles favicon requests
class Favicon implements CrimsonEndpoint {

  String pathToFavicon;
  
  Favicon([String this.pathToFavicon]);
  
  /// If [pathToFavicon] is null, attempts to load the favicon.ico in the 
  /// current folder, or the current folder/public.
  /// If [pathToFavicon] is not null, then it will attempt to load favicon.ico
  /// from that location
  void handle(request, response, CrimsonHttpServer server, void next([error])) {
    //TODO: add the favicon.
  }
  
  final String NAME = "FAVICON";
  
}
