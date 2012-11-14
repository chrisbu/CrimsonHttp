part of crimson_core;

class StaticFile implements CrimsonEndpoint {

  String rootPath;
  Logger logger;

  /// Loads the file from the path + the request.uri,
  /// eg: if the [rootPath] is ./public
  /// and the uri is /blah
  /// it will try to load the file ./public/blah
  /// if the uri is /blah/index.html
  /// it will try to load ./public/blah/index.html
  /// This handler will not return an error if it can't find the file.
  /// it will assume that a future endpoint will try to handle ie.
  StaticFile(String this.rootPath) {
    logger = LoggerFactory.getLogger("StaticFile");
  }

  Future<Map> handle(HttpRequest request, HttpResponse response, Map data) {
    Completer completer = new Completer();
    Uri p = new Uri(request.uri);
    String fileToLoad = "${this.rootPath}${p.path}";
    logger.debug("fileToLoad: ${fileToLoad}");

    onSuccess(List filedata) {
      logger.debug("Read file: ${fileToLoad}");
      //response.setHeader("Content-Type", "image/x-icon"); //todo - this properly
      response.headers.add(HttpHeaders.CONTENT_LENGTH, "${filedata.length}");
      //TODO: add other headers
      response.outputStream.write(filedata);
      completer.complete(data);
    }

    onNotFound() {
      //if the file isn't found, but there wasn't another error
      completer.complete(data);
    }

    _loadFromPath(fileToLoad, onSuccess, onNotFound, fail(exception) {
      Options o = new Options();
      print(o.script);
      completer.completeException(exception);
    });

    return completer.future;
  }

  _loadFromPath(String path, success(List data), onNotFound(), fail(exception)) {

    logger.debug("_loadFromPath: $path");

    File file = new File(path);

    //file.fullPath((String fullPath) => print(fullPath));
    file.exists().then((exists) {
      logger.debug("in exists callback: ${path}, ${exists}");
      if (exists) {
        file.readAsBytes().then((b)=>success(b));
      }
    });
//    file.onError = (Exception error) {
//      logger.debug("${path} doesn't exist: ${error}");
//      fail(error);
//    };

    logger.debug("trying to open file: ${path}");
//    file.exists((bool exists) {
//      logger.debug("in exists callback: ${path}, ${exists}");
//      if (exists) {
//        logger.debug("${path} exists, so reading");
//        file.readAsBytes( (List buffer) {
//          logger.debug("successfully read ${path}");
//          success(buffer);
//        });
//      }
//      else {
//        logger.debug("${path} doesn't exist");
//        onNotFound();
//      }
//    });
  }

  final String NAME = "StaticFile";

  var server;

}
