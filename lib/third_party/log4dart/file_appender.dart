// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

#library('log4dart:file');

#import("dart:io");
#import("log4dart.dart");

#source("lib/appenders/file_appender.dart");

/**
 * Appender that logs to a file
 */
interface FileAppender extends Appender default _FileAppender {
  FileAppender(String path);
}

