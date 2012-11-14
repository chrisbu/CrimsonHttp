part of crimson_core;

class Route implements CrimsonEndpoint {
  var _name;
  var _path;
  var _method;
  var _handler;
  var logger;
  var _routeItentifier;
  var _matcher;
  CrimsonHttpServer server;

  ///Creates the route, which will match the path and method, and pass the
  ///request ,response and data into the handler.
  ///The handler should return a future (or null).  When the future is complete
  ///or null is returned, the output stream will be closed.
  ///The future could return an exception.
  Route(String this._path, String this._method, Future handler(HttpRequest, HttpResponse, Map)) {
    _name = "ROUTE:${_method}:${_path}";
    logger = LoggerFactory.getLogger(_name);
    _handler = handler;

  }

  /// Allow matching with a custom _matcher function, which should return true or false.
  /// The [routeIdentifier] is provided to provide a way to log
  Route.withMatcher(bool this._matcher(HttpRequest req), String _routeIdentifier, Future handler(HttpRequest, HttpResponse, Map)) {
    _name = "ROUTE:matcher:${_routeIdentifier}";
    logger = LoggerFactory.getLogger(_name);
    _handler = handler;
  }

  Future<Map> handle(HttpRequest req, HttpResponse res, Map data) {
    logger.debug("Request:${req.method}:${req.path} - Handler:${this._method}:${this._path}");
    bool isMatched = false;
    if (this._matcher != null) {
      if (_matcher(req)) {
        isMatched = true;
      }
    }
    else if (req.path == this._path && req.method == this._method) {
      isMatched = true;
    }
    else {
      //TODO: Add regex matching
    }

    if (isMatched) {
      logger.debug("Routable handler for request: ${_name}");
      Completer completer = new Completer();

      Future handlerComplete = _handler(req,res,data);

      if (handlerComplete != null) {
        logger.debug("handling");
        handlerComplete.then((completeData) => onSuccess(res, completer, data));
        handlerComplete.handleException((error) => completer.completeException(error));
      }
      else {
        onSuccess(res, completer,data);
      }

      return completer.future;
    }
    else {
      return null;
    }
  }

  onSuccess(res, completer, data) {
    data["SUCCESS"] = true;
    res.outputStream.close();
    completer.complete(data);
  }

  String get NAME => _name;

}
