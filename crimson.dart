#library("crimson:core");

#import("lib/http.dart");
#import("dart:io");
#source('crimson_impl.dart');
#source('crimson_utils.dart');


/// Crimson is a set of HTTP middleware for Dart, loosely based upon 
/// sencha connect [https://github.com/senchalabs/connect]
/// --- 
/// It allows for filters and endpoints (collectively known as handlers, which
/// implement [CrimsonHandler]) to be added to the http request response  
/// cycle.
/// Filters (which implement [CrimsonFilter]) make use of the request 
/// response (possibly adding to the request or response, 
/// but don't end the flow.
///
/// Endpoints (which implement [CrimsonEndpoint]) make use of the request 
/// response, and also end the flow (ie, an endpoint will end the response).
/// 
/// All filters will be called, but Endpoints will stop on the first matching
/// endpoint.
/// Usage: 
///     CrimsonHttp http = new CrimsonHttp();
///     http.filters
///          .add(new Logger())
///          .add(new Session("mySessionKey"))
///          .add(/*...any CrimsonFilter implementation...*/);
///     http.endpoint
///          .add(new Favicon())
///          .add(new StaticFiles("/public"))
///          .add(new Route("/details/{id}",(req,res) => someCallback(req,res));
///          .add(/*...any CrimsonEndpoint implementation...*/);            
interface CrimsonHttpServer default _CrimsonHttpServer {
  
  /// Creates the [CrimsonHttpServer].  Takes an optional 
  /// [HTTPServer] implementation which may have already been created.
  /// If none is supplied, then it creates it's own internal instance
  /// of [HTTPServer] 
  CrimsonHttpServer([HTTPServer httpServer]);
  
  
  /// Contains a list of [CrimsonFilter] implementations.
  /// Filters will be called in turn before the endpoints are called.
  /// Each [CrimsonFilter] will be called in turn, and will hand over
  /// to the next filter.
  CrimsonHandlerList<CrimsonFilter> get filters();
  
  /// Contains a list of [CrimsonEndpoint] implementations.
  /// Each endpoint will be called in turn, and try to match the data 
  /// provided in the request.
  /// The first endpoint to match will handle the request and close 
  /// the response
  CrimsonHandlerList<CrimsonEndpoint> get endpoints();
  
  
  /// Starts the server listening for requests
  listen(String host, int port);
  
  /// A [Logger] implementation that the [CrimsonHttpServer] and its 
  /// handlers can make use of.
  CrimsonLogger logger;
  
}

/// Contains a list of [CrimsonHandler].  Is used by [CrimsonHttpServer] to
/// contain the list of filters and endpoints
interface CrimsonHandlerList<E extends CrimsonHandler> 
                   extends Iterable<E> 
                   default _CrimsonHandlerList {
  
  ///default constructor
  CrimsonHandlerList();                     
                     
  /// Adds a [CrimsonHandler] to the list.  
  /// Returns itself to allow for 
  /// method chaining, such as 
  ///     new CrimsonHttpServer().filters
  ///           .add(...)
  ///           .add(...)
  ///           .add(...etc...);
  CrimsonHandlerList add(CrimsonHandler handler); 
}

/// A [CrimsonHandler] 
interface CrimsonHandler {
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
  void handle(HTTPRequest request, HTTPResponse response, 
              CrimsonHttpServer server, 
              void next([CrimsonHttpException error]), 
              [void success()]);  
  
  /// The [name] by which we can identify the handler.  This is used in logging.
  /// It should be set as a constant value in any implementations.
  String get NAME();
  
  /// The [logLevel] to which the handler will output to the standard crimson
  /// logger.  
  /// For example, if the logLevel is Logger.DEBUG, then all debug and above
  /// messages will be shown for this handler.
  int logLevel;
  
  
}


/// Filters (which implement [CrimsonFilter]) make use of the request & 
/// response (possibly adding to the request or response), 
/// but don't end the flow.
interface CrimsonFilter extends CrimsonHandler  {
 
}

/// Endpoints (which implement [CrimsonEndpoint]) make use of the request & 
/// response, and also end the flow (ie, an endpoint will end the response).
interface CrimsonEndpoint extends CrimsonHandler {
  
}

/// [CrimsonLogger] interface.  Allows handlers to make use of a logger.
interface CrimsonLogger {
  static final int TRACE = 0;
  static final int DEBUG = 1;
  static final int INFO = 2;
  static final int WARN = 3;
  static final int ERROR = 4;
  
  static final List<String> LEVEL_TEXT = const["TRACE", "DEBUG", "INFO", "WARN", "ERROR"];
  
  void log(String message, int level);
  void trace(String message); 
  void debug(String message); 
  void info(String message); 
  void warn(String message); 
  void error(String message);
}

/// Exception handler which takes the [status] and the [message]
class CrimsonHttpException implements HTTPException {
  
  CrimsonHttpException(this.status, this.message, [this.stack=null]);
  
  final int status;
  final String message;
  final String stack;
  
  toString() {
    return stack == null ? "${status}: ${message}" : "${status}: ${message}\n${stack}";    
  }
}