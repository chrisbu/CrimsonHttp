
/// Base logger which simply forwards the log messages
/// to the log function.
class BaseLogger implements CrimsonLogger {
  
  void trace(String message) => log(message, TRACE);
  void debug(String message) => log(message, DEBUG);
  void info(String message) => log(message, INFO);
  void warn(String message) => log(message, WARN);
  void error(String message) => log(message, ERROR);
  
}


class SimpleLogger extends BaseLogger implements CrimsonLogger {
  /// The log level to log.
  int defaultLevel = ERROR; //the default level for all logging
  
  int logLevel = INFO; //default level for this class is WARN
  
  final String NAME = "LOGGER";
  
  /// Constructor.  
  /// [defaultLevel] defines the global log level for calls into this clase
  /// Optional [logLevel] defines the log level for this class.  
  SimpleLogger(this.defaultLevel, [this.logLevel = INFO]);
  //TODO: This probably needs thinking about a bit more.
  
  /// [CrimsonHandler.handle] implementation
  /// Provides INFO level logging of the [request.method] and [request.uri]
  void handle(HTTPRequest request, response, server, next) {
    //provide info logging of the request.
    try {
      info("${request.method}: ${request.uri}");
    }
    catch (var ex) {
      print(ex);
    }
    finally {
      next();  
    }
    
  }
  
  void log(String message, int level) {
    if (level >= defaultLevel) {
      print("${new Date.now()} - ${LEVEL_TEXT[level]} - ${message}");
    }
  }
  
}

