/// Handles favicon requests
/// If [pathToFavicon] is null, then it
/// servers the favicon in the current folder, or the
/// {current folder}/public/favicon.ico

part of crimson_core;

class Favicon implements CrimsonEndpoint {

  String pathToFavicon;
  Logger logger;

  Favicon([String this.pathToFavicon = null]) {
    logger = LoggerFactory.getLogger("Favicon");
  }

  CrimsonHttpServer server;

  /// If [pathToFavicon] is null, attempts to load the favicon.ico in the
  /// current folder, or the current folder/public.
  /// If [pathToFavicon] is not null, then it will attempt to load favicon.ico
  /// from that location
  Future<Map> handle(HttpRequest request, HttpResponse response, Map data) {
    Completer completer = new Completer();

    //check whether this request is for favicon.
    if (request.uri.endsWith("/favicon.ico") == false) {
      //if not, simply exit by calling next, and returing.
      //server.logger.debug("Request is not for favicon");
      logger.debug("not for favicon, so completing");
      return null;
    }

    logger.debug("Handling favicon");

    //otherwise, this request is for the favicon.
    onSuccess(List filedata) {
      response.headers.add(HttpHeaders.CONTENT_TYPE, "image/x-icon");
      response.headers.add(HttpHeaders.CONTENT_LENGTH, "${filedata.length}");
      response.headers.add(HttpHeaders.CACHE_CONTROL, "public, max-age=86400"); //1 day
      response.outputStream.write(filedata);
      completer.complete(data);
    };

    on404NotFound() {
      logger.debug("favicon not found");
      response.statusCode = HttpStatus.NOT_FOUND;
      data["SUCCESS"] = true;
      completer.complete(data);
    };

    if (this.pathToFavicon == null) {
      _loadFromPath("./favicon.ico", onSuccess, fail() {
        //failure handler - try the next in line...
        _loadFromPath("./public/favicon.ico", onSuccess, on404NotFound);
      });
    }
    else {
      //load from the custom path set.
      _loadFromPath(pathToFavicon, onSuccess, on404NotFound);
    }

    return completer.future;
  }


  _loadFromPath(String path, success(List data), on404NotFound()) {
    File file = new File(path);

//    file.onError = (Exception error) {
//      logger.debug("${path} doesn't exist: ${error}");
//      on404NotFound();
//    };


    logger.debug("NOT IMPLEMENTED trying to open favicon");

//    file.exists((bool exists) {
//      if (exists) {
//        logger.debug("${path} exists, so reading");
//        file.readAsBytes((List buffer) {
//          server.logger.debug("successfully read ${path}");
//          success(buffer);
//        });
//      }
//      else {
//        logger.debug("${path} doesn't exist");
//        on404NotFound();
//      }
//    });

  }


  final String NAME = "FAVICON";

}
