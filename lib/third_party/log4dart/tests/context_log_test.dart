// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class ContextLogTest {  
  ContextLogTest(): _logger = LoggerFactory.getLogger("ContextLogTest") {
    _logger.putContext("context", "context-message");
    try {
      _logger.debug("started tracking context");
      
      // the logger in simple log test inherits the context setup above;
      new SimpleLogTest();
    } finally {
      _logger.removeContext("context");
    }
  }
  
  final Logger _logger;
}
