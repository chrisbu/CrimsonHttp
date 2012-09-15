// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class LoggerConfigMap {
  LoggerConfigMap()
    : _configs = new Map<String, LoggerConfig>();
  
  LoggerConfig operator [](String loggerName) {
    if(!_configs.containsKey(loggerName)) {
      if(!_configs.containsKey("*")) {
        var defaultConfig = new LoggerConfig();
        defaultConfig.debugEnabled = true;
        defaultConfig.errorEnabled = true;
        defaultConfig.infoEnabled = true;
        defaultConfig.warnEnabled = true;
        defaultConfig.appenders = [ new ConsoleAppender() ];
        defaultConfig.logFormat = "[%d] %c %n:%x %m";
      
        _configs["*"] = defaultConfig;
      }
      var defaults = _configs["*"];
      _configs[loggerName] = defaults.clone();
    }
    return _configs[loggerName];
  }
  
  forEach(Function f) {
    return _configs.forEach(f);
  }
  
  final Map<String, LoggerConfig> _configs;
}