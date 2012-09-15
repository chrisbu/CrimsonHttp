// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * - c: Output the level (category) of the logging event
 * - d: Output the date when the log message was recorded
 * - m: Output the actual logging message
 * - n: Output the name of the logger that recorded the log
 * - x: Output the context of the logger
 */ 
class LogRecordFormatter {
  LogRecordFormatter(String _logFormat)
    : recordContext = false,
      _formatters = new List<_RecordFormatter>()
  {
    _formatReader = new _LogFormatReader(_logFormat);
    _parseLogFormat();
  }
  
  _parseLogFormat() {
    while(_hasMore()) {
      _currentChar = _peek(); 
      _advance();
      if(_currentChar == " ") {
        _parseSpace();
      } else if(_currentChar == "%") {
        // we have a punctuator
        _currentChar = _peek();
        _advance();
        if(_currentChar == "c") {
          _parseCategory();
        } else if(_currentChar == "d") {
          _parseDate();
        } else if(_currentChar == "m") {
          _parseMessage();
        } else if(_currentChar == "n") {
          _parseName();
        } else if(_currentChar == "x") {
          recordContext = true;
          _parseContext();
        } else {
          throw new IllegalArgumentException("illegal format ${_currentChar} in ${_formatReader.toString()}");
        }
      } else {
        _parseText();      
      }
    }
  }
  
  _parseSpace() {
    String space = " ";
    while(_hasMore() && _peek() == " ") {
      _advance();
      space = space.concat(" ");
    }
    _formatters.add((LogRecord record) => space);
  }
  
  _parseCategory() {
    _formatters.add((LogRecord record) => record.logLevel.name);
  }
  
  _parseDate() {
    _formatters.add((LogRecord record) => record.date.toString());
  }
  
  _parseMessage() {
    _formatters.add((LogRecord record) => record.message);
  }
  
  _parseName() {
    _formatters.add((LogRecord record) => record.loggerName);
  }
  
  _parseContext() {
    _formatters.add((LogRecord record) => record.context);
  }
  
  _parseText() {
     String text = "${_currentChar}";
     while(_hasMore() && _peek() != "%") {
       text = text.concat(_peek());
       _advance();
     }
     _formatters.add((LogRecord record) => text);
  }
  
  String _peek([int distance = 0]) => _formatReader.peek(distance);
      
  _advance() => _formatReader.advance();
  
  bool _hasMore() => _peek() != "";
  
  String format(LogRecord record) {
    var res = "";
    _formatters.forEach((_RecordFormatter formatter) => res = res.concat(formatter(record)));
    return res;
  }

  String _currentChar;
  _LogFormatReader _formatReader;
  bool recordContext;
  final List<_RecordFormatter> _formatters;
}

typedef String _RecordFormatter(LogRecord record);

