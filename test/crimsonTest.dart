#library('crimsonTest');

#import("../crimson.dart");
#import("../filters/filters.dart");
#import("../endpoints/endpoints.dart");
///Simple test server
main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  server.logger = new SimpleLogger(CrimsonLogger.TRACE);
  
  server.endpoints.add(new Favicon());
//  server.filters.add(new Logger(Logger.INFO));
//  server.filters.add(handler)
//     .add(handler)
//     .add(handler);
  
  server.listen("127.0.0.1", 8081);
}