// Copyright (C) 2012 Chris Buckett
// Use of this source code is governed by a MIT style licence
// can be found in the LICENSE file.
// website: 




/// Crimson is a set of HTTP middleware for Dart, loosely based upon 
/// sencha connect [https://github.com/senchalabs/connect]
/// --- 
/// It allows for filters and endpoints (collectively known as *handlers*, which
/// implement [CrimsonHandler]) to be added to the http request response  
/// cycle.
///
/// There are two interfaces which extend [CrimsonHandler]: [CrimsonFilter] and 
/// [CrimsonEndpoint]
///
/// Filters (which implement [CrimsonFilter]) make use of data on the request 
/// and possibly add to the repsonse, but don't close the response.
///
/// Endpoints (which implement [CrimsonEndpoint]) also can make use of the data
/// on the request, but when an endpoint writes to the response, it the 
/// response will be closed.  Endpoints try to match the data passed in on the
/// request, and if that endpoint matches the data, it will handle the request.
/// 
/// The filters and endpoints are executed in the order that they are added to
/// the server.  The first endpoint to match, will handle the response, and the
/// flow will end.
/// 
/// *Usage:* 
///     CrimsonHttp http = new CrimsonHttp();
///     http.use(new Logger())
///          .endpoint(new Favicon())
///          .filter(new Session("mySessionKey"))                    
///          .filter(/*...any CrimsonFilter implementation...*/);
///          .endpoint(new StaticFiles("/public"))
///          .endpoint(new Route("/details/{id}",(req,res) => someCallback(req,res));
///          .endpoint(/*...any CrimsonEndpoint implementation...*/);
/// 
/// There is no actual distinction between the [endpoint(CrimsonEndpoint)] 
/// and the [filter(CrimsonFilter)] functions - they are included to aid 
/// readability.  You can also use the more generic  more generic 
/// [add(CrimsonHandler)] function.
interface CrimsonHttpServer default _CrimsonHttpServer {
  
  /// Creates the [CrimsonHttpServer].  Takes an optional 
  /// [HTTPServer] implementation.
  /// If none is supplied, then it creates it's own internal instance
  /// of [HTTPServer] 
  CrimsonHttpServer([HttpServer httpServer]);
  
  /// Starts the server listening for requests
  listen(String host, int port);
  
  /// A list of independent modules.  Each module runs in its own
  /// isolate, and is matched based upon the uri passed in.
  /// The key should somehow match the request url or url/path
  /// to allow hosting multiple, independent sites on the same server
  /// The value is the path to the isolate
  /// TODO: Allow this to be loaded from config  
  LinkedHashMap<String, CrimsonModule> get modules();
  
  /// A [Logger] implementation that the [CrimsonHttpServer] and its 
  /// handlers can make use of.
  Logger logger;
  
}
//
///// The CrimsonModule is an [Isolate] which maintains 
//interface CrimsonModule {
//  
//  /// Contains a list of [CrimsonHandler] implementations.
//  /// Handler can be either one of a [CrimsonFilter] or [CrimsonEndpoint]
//  /// implementation.  Each filter or endpoint will be called in turn
//  /// until an endpoint matches and handles the request
//  CrimsonHandlerList<CrimsonHandler> get modules();
//  
//}

/// Contains a list of [CrimsonHandler].  Is used by [CrimsonHttpServer] to
/// contain the list of filters and endpoints
interface CrimsonHandlerList<E extends CrimsonHandler> 
                   extends Iterable<E> 
                   default _CrimsonHandlerList {
  
  ///default constructor
  CrimsonHandlerList(CrimsonHttpServer owner);                     
                     
  /// Adds a [CrimsonHandler] to the list.  
  /// Returns itself to allow for 
  /// method chaining, such as 
  ///     new CrimsonHttpServer().filters
  ///           .add(...)
  ///           .add(...)
  ///           .add(...etc...);
  CrimsonHandlerList add(CrimsonHandler handler);
  
  CrimsonHandlerList addEndpoint(CrimsonEndpoint endpoint);
  
  CrimsonHandlerList addFilter(CrimsonFilter filter);
}

/// A [CrimsonHandler] 
interface CrimsonHandler {
  
  /// The [name] by which we can identify the handler.  This is used in logging.
  /// It should be set as a constant value in any implementations.
  String get NAME();
  
  /// The [CrimsonHttpServer] to which this handler belongs.
  /// The handler can use this reference to access things like logger etc...
  CrimsonHttpServer server;
  
  Future<CrimsonData> handle(HttpRequest req, HttpResponse res, CrimsonData data);
}


/// Filters (which implement [CrimsonFilter]) make use of the request & 
/// response (possibly adding to the request or response), 
/// but don't end the flow.
interface CrimsonFilter extends CrimsonHandler  {
  /// Takes the [request] and [response] from the HTTPServer implementation 
  /// and a next function which should be called when the handler has completed
  /// This allows that async handlers can guarentee to have finished 
  /// before the next handler in the chain is called.
  /// [server] represents the server which is passing calling this handler.  This
  /// allows the handler to make use of various things that the server exposes, such
  /// as [logger].
  /// If [next] is not called, then no more handlers will be called, and the 
  /// response will be sent back to the client.  This is desirable for an
  /// endpoint which has not handled the request.
  
  
}

/// Endpoints (which implement [CrimsonEndpoint]) make use of the request & 
/// response, and also end the flow (ie, an endpoint will end the response).
interface CrimsonEndpoint extends CrimsonHandler {
/// Takes the [request] and [response] from the HTTPServer implementation 
  /// and a next function which should be called when the handler has completed
  /// This allows that async handlers can guarentee to have finished 
  /// before the next handler in the chain is called.
  /// [server] represents the server which is passing calling this handler.  This
  /// allows the handler to make use of various things that the server exposes, such
  /// as [logger].
  /// If [next] is not called, then no more handlers will be called, and the 
  /// response will be sent back to the client.  This is desirable for an
  /// endpoint which has not handled the request.
  /// optional [success] callback when a handler successfully handles 
  /// the request.
   
  
}

interface CrimsonData<K, V> extends Map<K, V>
                            default _CrimsonData<K, V> {
   /** Constructor with default implementation */                           
   CrimsonData();
  
}

/** An default implementation */
class _CrimsonData<K, V> implements CrimsonData {
  /** a delegate that implements a given methods */
  Map<K, V> _delegate;
  
  _CrimsonData() {
    _delegate = new Map();  
  }
  
  /**
   * Returns whether this map contains the given [value].
   */
  bool containsValue(V value) {
    return _delegate.containsValue(value);
  }

  /**
   * Returns whether this map contains the given [key].
   */
  bool containsKey(K key) {
    return _delegate.containsKey(key);
  }

  /**
   * Returns the value for the given [key] or null if [key] is not
   * in the map. Because null values are supported, one should either
   * use containsKey to distinguish between an absent key and a null
   * value, or use the [putIfAbsent] method.
   */
  V operator [](K key) {
    return _delegate[key];
  }

  /**
   * Associates the [key] with the given [value].
   */
  void operator []=(K key, V value) {
    _delegate[key] = value;
  }

  /**
   * If [key] is not associated to a value, calls [ifAbsent] and
   * updates the map by mapping [key] to the value returned by
   * [ifAbsent]. Returns the value in the map.
   */
  V putIfAbsent(K key, V ifAbsent()) {
    _delegate.putIfAbsent(key, ifAbsent);
  }

  /**
   * Removes the association for the given [key]. Returns the value for
   * [key] in the map or null if [key] is not in the map. Note that values
   * can be null and a returned null value does not always imply that the
   * key is absent.
   */
  V remove(K key) {
    _delegate.remove(key);
  }

  /**
   * Removes all pairs from the map.
   */
  void clear() {
    _delegate.clear();
  }

  /**
   * Applies [f] to each {key, value} pair of the map.
   */
  void forEach(void f(K key, V value)) {
    _delegate.forEach(f);
  }

  /**
   * Returns a collection containing all the keys in the map.
   */
  Collection<K> getKeys() { 
    return _delegate.getKeys();
  }

  /**
   * Returns a collection containing all the values in the map.
   */
  Collection<V> getValues() { 
    return _delegate.getValues();
  }

  /**
   * The number of {key, value} pairs in the map.
   */
  int get length() {
    return _delegate.length;
  }

  /**
   * Returns true if there is no {key, value} pair in the map.
   */
  bool isEmpty() {
    return _delegate.isEmpty();    
  }
  
}

/// Exception handler which takes the [status] and the [message]
class CrimsonHttpException extends HttpException {
  
  CrimsonHttpException(this.status, this.msg, [this.stack=null]);
  
  final int status;
  final String msg;
  final String stack;
  
  toString() {
    return stack == null ? "${status}: ${msg}" : "${status}: ${msg}\n${stack}";    
  }
}

interface Session extends Map<String, Object> default SessionImpl {
  Session();
  
  void addOrReplace(String key, Object value);
}