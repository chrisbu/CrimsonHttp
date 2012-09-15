// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class _LogFormatReader {
  factory _LogFormatReader(String formatString) {
    Expect.isFalse(formatString == null && formatString.isEmpty(), "log format cannot be null or empty");
    return new _LogFormatReader._internal(formatString, formatString.length);
  }
  
  _LogFormatReader._internal(this._formatString, this._formatLength) {
    _position = 0;
  }
  
  String peek(int distance) {
    final int ahead = _position+distance;
    if (ahead >= _formatLength) {
      return "";
    }
    return _formatString.substring(ahead, ahead+_offset);
  }
  
  advance() {
    _position += _offset;
  }
  
  String toString() => _formatString;
  
  final int _offset = 1;
  final String _formatString;
  final int _formatLength;
  int _position;
}

