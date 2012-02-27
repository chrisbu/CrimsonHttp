/// Handles favicon requests
/// If [pathToFavicon] is null, then it 
/// servers the favicon in the current folder, or the 
/// {current folder}/public/favicon.ico
class Favicon implements CrimsonEndpoint {

  String pathToFavicon;
  
  Favicon([String this.pathToFavicon = null]);
  
  /// If [pathToFavicon] is null, attempts to load the favicon.ico in the 
  /// current folder, or the current folder/public.
  /// If [pathToFavicon] is not null, then it will attempt to load favicon.ico
  /// from that location
  void handle(HTTPRequest request, HTTPResponse response, CrimsonHttpServer server, void next(var error), [void success()]) {
    
    //check whether this request is for favicon.
    if (request.uri.endsWith("/favicon.ico") == false) {
      //if not, simply exit by calling next, and returing.
      //server.logger.debug("Request is not for favicon");
      return next(null);
    }
    
    server.logger.debug("Handling favicon");
    
    //otherwise, this request is for the favicon.
    onSuccess(List data) {
      response.setHeader("Content-Type", "image/x-icon");
      response.setHeader("Content-Length", "${data.length}");
      response.setHeader("Cache-Control", "public, max-age=86400"); //1 day
      response.writeList(data, 0, data.length);
      success();
    };
    
    on404NotFound() {
      CrimsonHttpException ex = new CrimsonHttpException(HTTPStatus.NOT_FOUND, "favicon.ico not found");
      next(ex);
    };
    
    if (this.pathToFavicon == null) {
      _loadFromPath(server, "./favicon.ico", onSuccess, fail() {
        //failure handler - try the next in line...
        _loadFromPath(server, "./public/favicon.ico", onSuccess, on404NotFound);
      });  
    }
    else {
      //load from the custom path set.
      _loadFromPath(server, pathToFavicon, onSuccess, on404NotFound);
    }
    
    
    
    
  }
  
  
  _loadFromPath(server, String path, success(List data), fail()) {
    File file = new File(path);
    
    file.fullPathHandler = (String fullPath) {
      print(fullPath);
    };
    file.fullPath();
    
    file.readAsBytesHandler = (List buffer) {
      server.logger.debug("successfully read ${path}");
      success(buffer);
    };
    
    
    file.errorHandler = (String error) {
      server.logger.debug("${path} doesn't exist: ${error}");
      fail();
    };
    
    file.existsHandler = (bool exists) {
      if (exists) {
        server.logger.debug("${path} exists, so reading");
        file.readAsBytes();
      }
      else {
        server.logger.debug("${path} doesn't exist");
        fail();
      }
    };
    
    server.logger.debug("trying to open file");
    file.exists();
  }
  
  
  final String NAME = "FAVICON";
  
}
