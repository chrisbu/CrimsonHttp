
class _CrimsonHttpServer implements CrimsonHttpServer {
  /// Contains the complete list of filters which implement [CrimsonFilter]
  CrimsonHandlerList<CrimsonFilter> get filters() => _filters;
  
  /// Contains the complete list of handlers which implement [CrimsonEndpoint]
  CrimsonHandlerList<CrimsonEndpoint> get endpoints() => _endpoints;
  
  /// Contains the logger (which will default to [_NullLogger] if not otherwise
  /// defined
  CrimsonLogger logger;
  
  
  /// Constructor
  _CrimsonHttpServer([HTTPServer httpServer]) :
    //if the optional parameter hasn't been passed, then create
    //a new HTTPServer
    _httpServer = httpServer == null ? new HTTPServer() : httpServer,
    logger = new _NullLogger()
  {
    //would prefer to make these final, but we don't have access
    //to this at that point.
    _filters = new CrimsonHandlerList<CrimsonFilter>();
    _endpoints = new CrimsonHandlerList<CrimsonEndpoint>();
    _httpServer.errorHandler = _errorHandler;
  }
  
  /// Start listening on the [host] and [port] provided.
  /// Calls the internal [_onRequestHandler] method when a request is received
  /// which internall processes all the filters and tries to find an endpoint.
  listen(String host, int port) {
    _httpServer.listen(host, port, _onRequestHandler);
    print("Listening on ${host}:${port}");
  }
  
  /// This is the core of method of [CrimsonHttpServer]
  /// It first loops through each of the [filters] in turn, calling handle
  /// on each, and then loops through each of the [endpoints] until an endpoint
  /// has handled the request and populated the response.
  /// ---
  /// The loops need to be able to run async, and as such, each of the handle
  /// calls need to call next(); 
  _onRequestHandler(HTTPRequest req, HTTPResponse res) {
    logger.info("${req.method}: ${req.uri}");
    
    _processFilters(req,res);
    _processHandlers(req,res);
    
    res.writeDone();
  }
  
  /// Process all the [filters] in the list.
  /// If a filter generates an error, then it is logged, but we still contiune.
  _processFilters(HTTPRequest req, HTTPResponse res) {
    Iterator filterIterator = filters.iterator();
    CrimsonFilter filter = null;
    
    //closure to allow chaining async handlers
    next([error]) {
      if (error != null) {
        logger.error(error);  
      }
      
      if (filterIterator.hasNext()) {
        filter = filterIterator.next();
        filter.handle(req, res, this, ([error]) => next());
      }
      
    }
    
    //start the chain running by calling next();
    next();
  }
  
  /// Process all the [endpoints] in the list
  /// If an endpoint generates and error, it is logged, and we fail with a 500 
  _processHandlers(HTTPRequest req, HTTPResponse res) {
    Iterator endpointIterator = endpoints.iterator();
    CrimsonEndpoint endpoint = null;
    
    //recursive closure to allow chaining async handlers
    next([error]) {
      if (error != null) {
        //if there is an error, then END (no more recursing
        logger.error(error);  
      }
      else if (endpointIterator.hasNext()) {
        endpoint = endpointIterator.next();
        //call the handler, passing in this function to allow recursing.
        endpoint.handle(req, res, this, ([error]) => next([error]));
      }
      
    }
    
    //start the chain running by calling next();
    next();
  }
  
  _errorHandler(String err) {
    print("Default error handler: ${err}");
    //TODO: If an error handler filter has been registered, then use that.
    //Might be better to have an errorHandler collection in the same
    //way that we have filters and endpoints.
  }
  
  CrimsonHandlerList<CrimsonFilter> _filters;
  CrimsonHandlerList<CrimsonEndpoint> _endpoints;
  final HTTPServer _httpServer;
  
}



/// Contains the list of handlers that will be called in turn.
class _CrimsonHandlerList<E extends CrimsonHandler> implements CrimsonHandlerList<CrimsonHandler> {

  /// Rather than extending ListXYZ (because we can't extend the List<X> interface
  /// directly as it's an interface), we'll instead use an internal list, and 
  /// pass all the methods that would be overrideen to that list.
  final Map<String,CrimsonHandler> _internalMap;
  
  _CrimsonHandlerList() : 
    _internalMap = new Map<String,CrimsonHandler>()
   {
      //intentionally blank.
   }
    
  /// Add the handler and return the list to allow method chaining.  
  CrimsonHandlerList add(CrimsonHandler handler) {
    if (handler == null) {
      throw new IllegalArgumentException("[handler] cannot be null");
    }
    
    _internalMap[handler.NAME] = handler;
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



/// A defualt logger for [CrimsonHttpServer] to use
/// sends log messages no-where.
/// ensures that we don't end up with NPE when trying to log things.
class _NullLogger implements CrimsonLogger {
  void trace(String message) => null;
  void debug(String message) => null;
  void info(String message) => null;
  void warn(String message) => null;
  void error(String message) => null;
  void log(String message, int level) => null;
}
