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
  
  void handle(HTTPRequest request, HTTPResponse response, void next(var error), success()) {
    String fileToLoad = this.rootPath + request.uri;
    
    onSuccess(List data) {
      server.logger.debug("Read file: ${fileToLoad}");
      response.setHeader("Content-Length", data.length.toString());
      //TODO: add other headers
      response.writeList(data, 0, data.length);
      success();
    }
    
    _loadFromPath(fileToLoad, onSuccess, fail() => next(null)); 
  }
  
  _loadFromPath(String path, success(List data), fail()) {
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
  
  final String NAME = "StaticFile";
  
  var server;
  
}
