
class _CrimsonHttpServer implements CrimsonHttpServer {
  
  /// Contains the [Logger]
  Logger logger;  
  
  /// Constructor
  _CrimsonHttpServer([HttpServer httpServer]) :
    //if the optional parameter hasn't been passed, then create
    //a new HttpServer
    _httpServer = httpServer == null ? new HttpServer() : httpServer,
    _modules = new LinkedHashMap<String,CrimsonModule>(), 
    //get a logger for the current class
    logger = LoggerFactory.getLogger("_CrimsonHttpServer")
  {
     //setup the error and request handlers
    _httpServer.onError = _httpErrorHandler;
    _httpServer.defaultRequestHandler = _onRequestHandler;    
  }
  
  /// Start listening on the [host] and [port] provided.
  /// Calls the internal [_onRequestHandler] method when a request is received
  /// which internally processes all the filters and tries to find an endpoint.
  listen(String host, int port) {
    // start the server listening
    _httpServer.listen(host, port);
    print("Listening on ${host}:${port}");
  } 
  
  /// This is the core of method of [CrimsonHttpServer]
  /// It first loops through each of the [filters] in turn, calling handle
  /// on each, and then loops through each of the [endpoints] until an endpoint
  /// has handled the request and populated the response.
  /// ---
  /// The loops need to be able to run async, and as such, each of the handle
  /// calls need to call next(); 
  _onRequestHandler(HttpRequest req, HttpResponse res) {
    //find the module that matches the request
    logger.debug("${req.method}: ${req.uri}");
    
    CrimsonModule module = null;
    for (String key in modules.getKeys()) {
      if (key.startsWith(req.path)) {
        module = modules[key];
        break;
      }  
    }
     
    //if no module found by path, and there is a default module, then use it.
    if (module == null && modules.containsKey("*")) {
      module = modules["*"];
    }
    
    if (module != null) {
      try {
        Future<CrimsonData> handled = module.handle(req,res);        
        handled.then((result) {
          try {
            res.outputStream.close();
          }
          catch (var ex, var stack) {
            print("${ex}, ${stack}");
          }
        });
        handled.handleException((error) {
          res.outputStream.close();
          _httpErrorHandler(error);
          return true; //this consider a given error to be handled.
        });
      }
      catch (var ex, var stack) {
        logger.error("${ex}, ${stack}");
      }
    }
    else {
      logger.debug("404, not found");
      res.statusCode = HttpStatus.NOT_FOUND;
      res.outputStream.close();
    }    
  }  
  
  _httpErrorHandler(Exception error) {
    print("we invocked http error handler");
    this.logger.error(error.toString());
  }  
  
  LinkedHashMap<String,CrimsonModule> get modules => _modules;
  
  final HttpServer _httpServer;
  final LinkedHashMap<String, CrimsonModule> _modules;  
}
