class Route implements CrimsonEndpoint {
  
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
      logger = LoggerFactory.getLogger("Route:${_method}:${_path}");
      _handler = handler;
  }
  
  Future<CrimsonData> handle(HttpRequest req, HttpResponse res, CrimsonData data) {
    if (req.path == this._path && req.method == this._method) {
      logger.debug("Routable handler for request:${req.method}:${req.path}");
      Completer completer = new Completer();
      
      Future handlerComplete = _handler(req,res,data);
      if (handlerComplete != null) {
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
    completer.complete(data);
  }
  
  String NAME = "ROUTE";

}
