
class Logger implements CrimsonFilter {
  
  final String NAME = "LOGGER";
  
  static final int TRACE = 0;
  static final int DEBUG = 1;
  static final int INFO = 2;
  static final int WARN = 3;
  static final int ERROR = 4;
  
  /// The log level to log.
  int defaultLevel = ERROR; //the default level for all logging
  
  int logLevel = WARN; //default level for this class is WARN
  
  Logger(this.defaultLevel, [this.logLevel]);
  
  void _log(String message, int level) {
    if (level >= defaultLevel) {
      print(message);  
    }
  }
  
  void log(CrimsonHandler handler, String message) {
    _log(message, handler.logLevel);
  }
  
  bool handle(request, response) {
    log(this, "Request received");
    return false;
  }

}
