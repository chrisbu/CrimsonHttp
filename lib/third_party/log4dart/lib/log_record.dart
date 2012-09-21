// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class LogRecord {
  LogRecord(this.message, this.logLevel, this.loggerName, this.context)
    : date = new Date.now();
  
  final Date date;
  final String message;
  final LogLevel logLevel;
  final String loggerName;
  final String context;
}

