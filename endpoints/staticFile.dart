class StaticFile implements CrimsonEndpoint {

  String rootPath;
  
  /// Loads the file from the path + the request.uri,
  /// eg: if the [rootPath] is ./public
  /// and the uri is /blah
  /// it will try to load the file ./public/blah
  /// if the uri is /blah/index.html
  /// it will try to load ./public/blah/index.html
  /// This handler will not return an error if it can't find the file.
  /// it will assume that a future endpoint will try to handle ie.
  StaticFile(String this.rootPath); 
  
  void handle(HttpRequest request, HttpResponse response, void next(var error), success()) {
    String fileToLoad = this.rootPath + request.uri;
    
    onSuccess(List data) {
      server.logger.debug("Read file: ${fileToLoad}");
      response.setHeader("Content-Length", data.length.toString());
      //TODO: add other headers
      response.outputStream.write(data);
      success();
    }
    
    _loadFromPath(fileToLoad, onSuccess, fail() => next(null)); 
  }
  
  _loadFromPath(String path, success(List data), fail()) {
    File file = new File(path);
    
    file.fullPath((String fullPath) => print(fullPath));
    
    file.onError = (String error) {
      server.logger.debug("${path} doesn't exist: ${error}");
      fail();
    };
    
    server.logger.debug("trying to open file");
    file.exists((bool exists) {
      if (exists) {
        server.logger.debug("${path} exists, so reading");
        file.readAsBytes( (List buffer) {
          server.logger.debug("successfully read ${path}");
          success(buffer);
        });
      }
      else {
        server.logger.debug("${path} doesn't exist");
        fail();
      }
    });
  }
  
  final String NAME = "StaticFile";
  
  var server;
  
}
