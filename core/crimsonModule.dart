class CrimsonModule  {
  
  var _server;
  var logger;
  
  CrimsonHandlerList<CrimsonHandler> _handlers;
  CrimsonHandlerList<CrimsonHandler> get handlers() => _handlers;
  
  CrimsonModule(this._server)   {
    logger = LoggerFactory.getLogger("CrimsonModule");
    _handlers = new CrimsonHandlerList<CrimsonHandler>(_server);
  }
  
  Future handle(HttpRequest req, HttpResponse res) {
    logger.debug("New requst passed to module");
    
    CrimsonData data = new CrimsonData();
    
    Completer completer = new Completer();
    
    Iterator handlerIterator = handlers.iterator();
    handleNext() {
      if (data["SUCCESS"] != true) {
        if (handlerIterator.hasNext()) {
          CrimsonHandler handler = handlerIterator.next();
          logger.debug("trying handler: ${handler.NAME}");
          Future<CrimsonData> onHandled = handler.handle(req,res,data);
        
          //it is valid for a handler to return null, when they are not even 
          //going to attempt to try and handle it, for example, when the 
          // a favicon handler won't bother trying to handle a request
          // for index.html.  In this case, just go to the next
          // handler/
          if (onHandled != null) { 
            onHandled.then((result) {
              logger.debug("handler handled.");
              if (result["SUCCESS"] != true) {
                logger.debug("handler handled = false.");
                handleNext(); //recurse
              } else {
                completer.complete("handled");
              }
            });  
            onHandled.handleException((error) {
              print("error: ${error}");
              try {
                completer.completeException(error);
              }
              catch (var ex, var stack) {
                print(ex);
                print(stack);
              }
              return true;
            });
          }
          else {
            logger.debug("handler returned null - trying next");
            handleNext(); //recurse
          }         
        }
        else {
          completer.complete("all handled");    
        }
      }
      else {
        logger.info("Success=true");
        completer.complete("handled");
      }
    }
    
    handleNext();  //start the chain
    
    return completer.future;
  }
    
}
