
/// Base logger which simply forwards the log messages
/// to the log function.
class BaseLogger implements CrimsonLogger {
  
  void trace(String message) => log(message, CrimsonLogger.TRACE);
  void debug(String message) => log(message, CrimsonLogger.DEBUG);
  void info(String message) => log(message, CrimsonLogger.INFO);
  void warn(String message) => log(message, CrimsonLogger.WARN);
  void error(String message) => log(message, CrimsonLogger.ERROR);
  
}


class SimpleLogger extends BaseLogger implements CrimsonLogger {
  /// The log level to log.
  final int defaultLevel; //the default level for all logging
  
  final int logLevel; //default level for this class is WARN
  
  final String NAME = "LOGGER";
  
  /// Constructor.  
  /// [defaultLevel] defines the global log level for calls into this clase
  /// Optional [logLevel] defines the log level for this class.  
  SimpleLogger(this.defaultLevel, [int this.logLevel = CrimsonLogger.INFO]);
  
  //TODO: This probably needs thinking about a bit more.
  
  void log(String message, int level) {
    if (level >= defaultLevel) {
      String levelText = CrimsonLogger.LEVEL_TEXT[level];
      print("[${new Date.now()}-${levelText}] ${message}");
    }
  }
  
}

