
class _CrimsonHttpServer implements CrimsonHttpServer {
  /// Contains the complete list of filters which implement [CrimsonFilter]
  CrimsonHandlerList<CrimsonFilter> get filters() => _filters;
  
  /// Contains the complete list of handlers which implement [CrimsonEndpoint]
  CrimsonHandlerList<CrimsonEndpoint> get endpoints() => _endpoints;
  
  /// Contains the [logger]
  Logger logger;
  
  
  /// Constructor
  _CrimsonHttpServer([HttpServer httpServer]) :
    //if the optional parameter hasn't been passed, then create
    //a new HttpServer
    _httpServer = httpServer == null ? new HttpServer() : httpServer,
    logger = LoggerFactory.getLogger("_CrimsonHttpServer")
  {
    //would prefer to make these final, but we don't have access
    //to this at that point.
    _filters = new CrimsonHandlerList<CrimsonFilter>(this);
    _endpoints = new CrimsonHandlerList<CrimsonEndpoint>(this);
    _httpServer.onError = _httpErrorHandler;
  }
  
  /// Start listening on the [host] and [port] provided.
  /// Calls the internal [_onRequestHandler] method when a request is received
  /// which internall processes all the filters and tries to find an endpoint.
  listen(String host, int port) {
    _httpServer.onRequest = _onRequestHandler;
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
    HttpRequest request = req;
    logger.info("${req.method}: ${req.uri}");
    
    
    _processFilters(request,res,onAllComplete() {
      _processHandlers(req,res);  
    });
    
    
    
  }
  
  /// Process all the [filters] in the list.
  /// If a filter generates an error, then it is logged, but we still contiune.
  _processFilters(HttpRequest req, HttpResponse res, void onAllComplete()) {
    Iterator filterIterator = filters.iterator();
    CrimsonFilter filter = null;
    
    //closure to allow chaining async handlers
    next([CrimsonHttpException error]) {
      if (error != null) {
        print("in filter error handler: ${error}");
        logger.error(error.toString());  
      }
      
      if (filterIterator.hasNext()) {
        filter = filterIterator.next();
        try {
          filter.handle(req, res, (var err) => next(err));
        }
        catch (Exception ex, var stack){
          //call next, passing in the exception details so that we can log it.
          next(new CrimsonHttpException(HttpStatus.INTERNAL_SERVER_ERROR, ex, stack));
        } 
      }
      else {
        //call the onAllComplete handler when we've processed all the filters
        onAllComplete();
      }
      
    }
    
    //start the chain running by calling next();
    next();
  }
  
  /// Process all the [endpoints] in the list
  /// If an endpoint generates and error, it is logged, and we fail with a 500 
  _processHandlers(HttpRequest req, HttpResponse res) {
    Iterator endpointIterator = endpoints.iterator();
    CrimsonEndpoint endpoint = null;
    
    //recursive closure to allow chaining async handlers
    next([CrimsonHttpException error = null]) {
      
      if (error != null) {
        //if there is an error, then END (no more recursing - note the else...
        logger.error(error.toString());
        _crimsonErrorHandler(error,req,res);
      }
      else if (endpointIterator.hasNext()) {
        endpoint = endpointIterator.next();
        //call the handler, passing in this function to allow recursing.
        try {
          endpoint.handle(req, res, 
               (var err) => next(err), 
               success() => res.outputStream.close()); //second closure represents success
        }
        catch (Exception ex, var stack) {
          next(new CrimsonHttpException(HttpStatus.INTERNAL_SERVER_ERROR, ex, stack));
        }
      } else {
        //if we've got here, and there are no errors
        //then we've not found a matching endpoint, so return a 404 error.
        _crimsonErrorHandler(new CrimsonHttpException(HttpStatus.NOT_FOUND, "Not found"), req, res);
      }
      
    }
    
    //start the chain running by calling next();
    next();
  }
  
  _httpErrorHandler(String error) {
    CrimsonHttpException ex = new CrimsonHttpException(HttpStatus.INTERNAL_SERVER_ERROR, error);
    _crimsonErrorHandler(ex, null, null);
  }
  
  _crimsonErrorHandler(CrimsonHttpException error, HttpRequest req, HttpResponse res) {
    this.logger.error(error.toString());
    res.statusCode = error.status;
    res.setHeader("Content-Type", "text/plain");
    res.writeString("CrimsonHttp: Error\n");
    res.writeString(error.toString());
    res.writeString("\nMethod: ${req.method}: ${req.uri}");
    res.outputStream.close();
    //TODO: If an error handler filter has been registered, then use that.
    //Might be better to have an errorHandler collection in the same
    //way that we have filters and endpoints.
  }
  
  CrimsonHandlerList<CrimsonFilter> _filters;
  CrimsonHandlerList<CrimsonEndpoint> _endpoints;
  final HttpServer _httpServer;
  
}



/// Contains the list of handlers that will be called in turn.
class _CrimsonHandlerList<E extends CrimsonHandler> implements CrimsonHandlerList<CrimsonHandler> {

  /// Rather than extending ListXYZ (because we can't extend the List<X> interface
  /// directly as it's an interface), we'll instead use an internal list, and 
  /// pass all the methods that would be overrideen to that list.
  final Map<String,CrimsonHandler> _internalMap;
  
  final CrimsonHttpServer _server;
  
  _CrimsonHandlerList(CrimsonHttpServer owner) : 
    _internalMap = new Map<String,CrimsonHandler>(),
    _server = owner
   {
      //intentionally blank.
   }
    
  /// Add the handler and return the list to allow method chaining.  
  CrimsonHandlerList add(CrimsonHandler handler) {
    if (handler == null) {
      throw new IllegalArgumentException("[handler] cannot be null");
    }
    
    _internalMap[handler.NAME] = handler;
    handler.server = _server;
    return this;
  }
  
  CrimsonHandler operator[] (String key) {
    return _internalMap[key];
  }
  
  
  /* Override List implementation */ 
//  void addAll(Collection collection) => _internalList.addAll(collection);
//  void forEach(void f(E element)) => _internalList.forEach(f);
//  Collection map(f(CrimsonHandler)) => _internalList.map(f);
//  Collection filter(bool f(CrimsonHandler)) => _internalList.filter(f);
//  bool every(bool f(CrimsonHandler)) => _internalList.every(f);
//  bool some(bool f(CrimsonHandler)) => _internalList.some(f);
//  bool isEmpty() => _internalList.isEmpty();
    Iterator iterator() => _internalMap.getValues().iterator();
//  CrimsonHandler operator[](int i) => _internalList[i];
//  void operator []=(int index,value) => _internalList[index] = value;
//  int get length() =>  _internalList.length;
//  void addLast(CrimsonHandler value) => _internalList.addLast(value);
//  void sort(int compare(CrimsonHandler, CrimsonHandler)) => _internalList.sort(compare);
//  int indexOf(E element, [int start]) => _internalList.indexOf(element, start);
//  int lastIndexOf(E element, [int start]) => _internalList.lastIndexOf(element, start);
//  void clear() => _internalList.clear(); 
//  CrimsonHandler removeLast() => _internalList.removeLast();
//  void remove(int start, int l) => _internalList.removeRange(start, l);
//  CrimsonHandler last() => _internalList.last();
//  List getRange(int start, int l) => _internalList.getRange(start, l);
//  void setRange(int start, int l, List from, [int startFrom]) => _internalList.setRange(start, l, from, startFrom);
//  void removeRange(int start, int l) => _internalList.removeRange(start, l);
//  void insertRange(int start, int l, [CrimsonHandler initialValue]) => _internalList.insertRange(start, l, initialValue);
}

// TODO: Broken with the dart:io
//class _CrimsonHttpRequestImpl implements CrimsonHttpRequest {
//  Session session;
//  
//}

class SessionImpl implements Session {
  
  Map<String, Object> _internalList;
  
  bool containsValue(Object value) => _internalList.containsValue(value);
  
  bool containsKey(String key) => _internalList.containsKey(key);
  
  Object operator[](String key) => _internalList[key];
  
  void operator[]=(String key, Object value) {
    _internalList[key] = value;
  }
  
  Object putIfAbsent(String key, Object put()) => _internalList.putIfAbsent(key,put);
  
  Object remove(String key) => _internalList.remove(key);
  
  void clear() => _internalList.clear();
  
  void forEach(void f(String key, Object value)) {
    _internalList.forEach(f);
  }
  
  Collection getKeys() => _internalList.getKeys();
  
  Collection getValues() => _internalList.getValues();
  
  int get length() => _internalList.length;
  
  bool isEmpty() => _internalList.isEmpty();
}