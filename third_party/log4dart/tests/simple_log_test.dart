// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class SimpleLogTest {
  SimpleLogTest(): _logger = LoggerFactory.getLogger("SimpleLogTest") {
    _logger.debug("a debug message");
   
    if(_logger.infoEnabled) _logger.info("a info message");
    
    _logger.warn("a warning");
    
    _logger.error("a error");
  }
  
  final Logger _logger;
}
