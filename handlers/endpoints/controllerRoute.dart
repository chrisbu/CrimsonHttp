class ControllerRoute implements CrimsonEndpoint {  
  String _name;
  String _path;
  AppController _controller;
  var logger;
  CrimsonHttpServer server;
  
  /** Contruct route that forwards all matched requests to a given controller. */
  ControllerRoute(String this._path, AppController controller) {
    _name = "ROUTE:${_path}";
    logger = LoggerFactory.getLogger(_name);
    _controller = controller;
    controller.route = _path;
  }
  
  Future<CrimsonData> handle(HttpRequest req, HttpResponse res, CrimsonData data) {
    logger.debug("Request:${req.method}:${req.path} - Handler:${this._path}");
    bool isMatched = false;
    if (req.path.startsWith(this._path)) {
      isMatched = true;
    } else {
      //TODO: Add regex matching
    }
      
    if (isMatched) {
      logger.debug("Routable handler for request: ${_name}");
      Completer completer = new Completer();
      
      Future handlerComplete = _controller.handler(req,res,data);
      
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
    print("we successfully processed a route: ${_controller.route}");
    data["SUCCESS"] = true;
    res.outputStream.close();
    completer.complete(data);
  }
  
  String get NAME() => _name;
  
}

interface AppController {
  
  /** A base method that handles a http requests. */
  Future handler(HttpRequest, HttpResponse, CrimsonData);
  /** Path to the controller a knowledge about given route path. */
  void set route(String path);
  
  String get route();
}