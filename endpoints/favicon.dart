/// Handles favicon requests
/// If [pathToFavicon] is null, then it 
/// servers the favicon in the current folder, or the 
/// {current folder}/public/favicon.ico
class Favicon implements CrimsonEndpoint {

  String pathToFavicon;
  
  Favicon([String this.pathToFavicon]);
  
  int logLevel = CrimsonLogger.DEBUG;
  
  /// If [pathToFavicon] is null, attempts to load the favicon.ico in the 
  /// current folder, or the current folder/public.
  /// If [pathToFavicon] is not null, then it will attempt to load favicon.ico
  /// from that location
  void handle(HTTPRequest request, HTTPResponse response, CrimsonHttpServer server, void next([error]), [void success()]) {
    
    //check whether this request is for favicon.
    if (request.uri.endsWith("/favicon.ico") == false) {
      //if not, simply exit by calling next, and returing.
      server.logger.debug("Request is not for favicon");
      return next();
    }
    
    server.logger.debug("Handling favicon");
    
    //otherwise, this request is for the favicon.
    //lots of async calls here.
    
    //TODO: add the favicon.
    File file = new File("./favicon.ico");
    
    file.fullPathHandler = (String fullPath) {
      print(fullPath);
    };
    file.fullPath();
    
    file.readAsBytesHandler = (List buffer) {
      server.logger.debug("successfully read ./favicon");
      response.writeList(buffer, 0, buffer.length);
      success();
    };
    
    
    file.errorHandler = (String error) {
      server.logger.debug("./favicon doesn't exist");
    };
    
    file.existsHandler = (bool exists) {
      if (exists) {
        server.logger.debug("File exists, so reading");
        file.readAsBytes();
      }
      else {
        server.logger.debug("File doesn't exist");
      }
    };
    
    server.logger.debug("trying to open file");
    file.exists();
  }
  
  final String NAME = "FAVICON";
  
}
