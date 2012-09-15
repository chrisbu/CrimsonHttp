// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class LoggerConfig {
  bool debugEnabled;
  bool errorEnabled;
  bool infoEnabled;
  bool warnEnabled;
  String logFormat;
  List<Appender> appenders;  
  
  String toString() {
    var str = """
      debugEnabled: $debugEnabled\n
      errorEnabled: $errorEnabled\n
      infoEnabled: $infoEnabled\n
      warnEnabled: $warnEnabled\n
      format: $logFormat
    """;
    return str;
  }
  
  LoggerConfig clone() {
    LoggerConfig cfg = new LoggerConfig();
    cfg.debugEnabled = debugEnabled;
    cfg.errorEnabled = errorEnabled;
    cfg.infoEnabled = infoEnabled;
    cfg.warnEnabled = warnEnabled;
    cfg.logFormat = "$logFormat";
    cfg.appenders = new List.from(appenders);
    return cfg;
  }
}
