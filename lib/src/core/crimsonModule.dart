part of crimson_core;

class CrimsonModule  {

  var _server;
  var logger;

  CrimsonHandlerList<CrimsonHandler> _handlers;
  CrimsonHandlerList<CrimsonHandler> get handlers => _handlers;

  CrimsonModule(this._server)   {
    logger = LoggerFactory.getLogger("CrimsonModule");
    _handlers = new CrimsonHandlerList<CrimsonHandler>(_server);
  }

  Future handle(HttpRequest req, HttpResponse res) {
    logger.debug("New requst passed to module");

    var data = new Map();

    Completer completer = new Completer();

    Iterator handlerIterator = handlers.iterator();
    handleNext() {
      if (data["SUCCESS"] != true) {
        if (handlerIterator.hasNext) {
          CrimsonHandler handler = handlerIterator.next();
          print("trying handler: ${handler.NAME}");
          Future<Map> onHandled = handler.handle(req,res,data);

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
              }
            });
            onHandled.handleException((error) {
              print("error: ${error}");
              try {
                completer.completeException(error);
              }
              on Exception catch(e) {
                print(e);
//                print(stack);
                //res.outputStream.close();
              }

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
        res.outputStream.close();
      }
    }

    handleNext();  //start the chain

    return completer.future;
  }

//  CrimsonHandlerList<CrimsonFilter> _filters;
//  CrimsonHandlerList<CrimsonEndpoint> _endpoints;
//
//  ///TODO: Aggregate the filters and endpoints into handlers.
///// Contains the complete list of filters which implement [CrimsonFilter]
//  CrimsonHandlerList<CrimsonFilter> get filters() => _filters;
//
//  /// Contains the complete list of handlers which implement [CrimsonEndpoint]
//  CrimsonHandlerList<CrimsonEndpoint> get endpoints() => _endpoints;
//
//  /// Process all the [filters] in the list.
//  /// If a filter generates an error, then it is logged, but we still contiune.
//  _processFilters(HttpRequest req, HttpResponse res, void onAllComplete()) {
//    Iterator filterIterator = filters.iterator();
//    CrimsonFilter filter = null;
//
//    //closure to allow chaining async handlers
//    next([CrimsonHttpException error]) {
//      if (error != null) {
//        print("in filter error handler: ${error}");
//        logger.error(error.toString());
//      }
//
//      if (filterIterator.hasNext()) {
//        filter = filterIterator.next();
//        try {
//          filter.handle(req, res, (var err) => next(err));
//        }
//        catch (Exception ex, var stack){
//          //call next, passing in the exception details so that we can log it.
//          next(new CrimsonHttpException(HttpStatus.INTERNAL_SERVER_ERROR, ex, stack));
//        }
//      }
//      else {
//        //call the onAllComplete handler when we've processed all the filters
//        onAllComplete();
//      }
//
//    }
//
//    //start the chain running by calling next();
//    next();
//  }
//
//  /// Process all the [endpoints] in the list
//  /// If an endpoint generates and error, it is logged, and we fail with a 500
//  _processEndpoints(HttpRequest req, HttpResponse res) {
//    Iterator endpointIterator = endpoints.iterator();
//    CrimsonEndpoint endpoint = null;
//
//    //recursive closure to allow chaining async handlers
//    next([CrimsonHttpException error = null]) {
//
//      if (error != null) {
//        //if there is an error, then END (no more recursing - note the else...
//        logger.error(error.toString());
//        _crimsonErrorHandler(error,req,res);
//      }
//      else if (endpointIterator.hasNext()) {
//        endpoint = endpointIterator.next();
//        //call the handler, passing in this function to allow recursing.
//        try {
//          endpoint.handle(req, res,
//               (var err) => next(err),
//               success() => res.outputStream.close()); //second closure represents success
//        }
//        catch (Exception ex, var stack) {
//          next(new CrimsonHttpException(HttpStatus.INTERNAL_SERVER_ERROR, ex, stack));
//        }
//      } else {
//        //if we've got here, and there are no errors
//        //then we've not found a matching endpoint, so return a 404 error.
//        _crimsonErrorHandler(new CrimsonHttpException(HttpStatus.NOT_FOUND, "Not found"), req, res);
//      }
//
//    }
//
//    //start the chain running by calling next();
//    next();
//  }
//
//  handleRequest(req,res) {
//    HttpRequest request = req;
//    logger.info("${req.method}: ${req.uri}");
//
//
//    _processFilters(request,res,onAllComplete() {
//      _processEndpoints(req,res);
//    });
//  }

}
