
class _CrimsonHttpServer implements CrimsonHttpServer {
  CrimsonHandlerList<CrimsonFilter> get filters() => _filters;
  CrimsonHandlerList<CrimsonEndpoint> get endpoints() => _endpoints;
  
  CrimsonHandlerList<CrimsonFilter> _filters;
  CrimsonHandlerList<CrimsonEndpoint> _endpoints;
  
  final HTTPServer _httpServer;
  
  _CrimsonHttpServer([HTTPServer httpServer]) :
    //if the optional parameter hasn't been passed, then create
    //a new HTTPServer
    _httpServer = httpServer == null ? new HTTPServer() : httpServer
  {
    //would prefer to make these final, but we don't have access
    //to this at that point.
    _filters = new CrimsonHandlerList<CrimsonFilter>();
    _endpoints = new CrimsonHandlerList<CrimsonEndpoint>();
    _httpServer.errorHandler = _errorHandler;
  }
  
  ///Start listening on the [host] and [port] provided
  listen(String host, int port) {
      _httpServer.listen(host, port, _onRequestHandler);
      print("Listening on ${host}:${port}");
  }
  
  _onRequestHandler(HTTPRequest req, HTTPResponse res) {
    print("New request");
    //TODO: Complete this
  }
  
  _errorHandler(String err) {
    print("Default error handler: ${err}");
    //TODO: If an error handler filter has been registered, then use that.
    //Might be better to have an errorHandler collection in the same
    //way that we have filters and endpoints.
  }
}



/// Contains the list of handlers that will be called in turn.
class _CrimsonHandlerList<E extends CrimsonHandler> implements CrimsonHandlerList<CrimsonHandler> {

  /// Rather than extending ListXYZ (because we can't extend the List<X> interface
  /// directly as it's an interface), we'll instead use an internal list, and 
  /// pass all the methods that would be overrideen to that list.
  final List<CrimsonHandler> _internalList;
  
  _CrimsonHandlerList() : 
    _internalList = new List<CrimsonHandler>()
   {
      //intentionally blank.
   }
    
  /// Add the handler and return the list to allow method chaining.  
  CrimsonHandlerList add(CrimsonHandler handler) {
    _internalList.add(handler);
    return this;
  }
  
  
  /* Override List implementation */ 
  void addAll(Collection collection) => _internalList.addAll(collection);
  void forEach(void f(E element)) => _internalList.forEach(f);
  Collection map(f(CrimsonHandler)) => _internalList.map(f);
  Collection filter(bool f(CrimsonHandler)) => _internalList.filter(f);
  bool every(bool f(CrimsonHandler)) => _internalList.every(f);
  bool some(bool f(CrimsonHandler)) => _internalList.some(f);
  bool isEmpty() => _internalList.isEmpty();
  Iterator iterator() => _internalList.iterator();
  CrimsonHandler operator[](int i) => _internalList[i];
  void operator []=(int index,value) => _internalList[index] = value;
  int get length() =>  _internalList.length;
  void addLast(CrimsonHandler value) => _internalList.addLast(value);
  void sort(int compare(CrimsonHandler, CrimsonHandler)) => _internalList.sort(compare);
  int indexOf(E element, [int start]) => _internalList.indexOf(element, start);
  int lastIndexOf(E element, [int start]) => _internalList.lastIndexOf(element, start);
  void clear() => _internalList.clear(); 
  CrimsonHandler removeLast() => _internalList.removeLast();
  void remove(int start, int l) => _internalList.removeRange(start, l);
  CrimsonHandler last() => _internalList.last();
  List getRange(int start, int l) => _internalList.getRange(start, l);
  void setRange(int start, int l, List from, [int startFrom]) => _internalList.setRange(start, l, from, startFrom);
  void removeRange(int start, int l) => _internalList.removeRange(start, l);
  void insertRange(int start, int l, [CrimsonHandler initialValue]) => _internalList.insertRange(start, l, initialValue);
}