class Route implements CrimsonEndpoint {
  var _name;
  var _path;
  var _method;
  var _handler;
  var logger;
  CrimsonHttpServer server;
 
  ///Creates the route, which will match the path and method, and pass the 
  ///request ,response and data into the handler.
  ///The handler should return a future (or null).  When the future is complete
  ///or null is returned, the output stream will be closed.
  ///The future could return an exception.
  Route(String this._path, String this._method, Future handler(HttpRequest, HttpResponse, CrimsonData)) {
    _name = "ROUTE:${_method}:${_path}";
    logger = LoggerFactory.getLogger(_name);
    _handler = handler;
    
  }
  
  Future<CrimsonData> handle(HttpRequest req, HttpResponse res, CrimsonData data) {
    logger.debug("Request:${req.method}:${req.path} - Handler:${this._method}:${this._path}");
    if (req.path == this._path && req.method == this._method) {
      logger.debug("Routable handler for request:${req.method}:${req.path}");
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
  
  String get NAME() => _name;

}
