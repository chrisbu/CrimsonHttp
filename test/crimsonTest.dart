#library('crimsonTest');

#import("../crimson.dart");
#import("../filters/filters.dart");

///Simple test server
main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  server.filters.add(new Logger(Logger.WARN, Logger.WARN));
//  server.filters.add(handler)
//     .add(handler)
//     .add(handler);
  
  server.listen("127.0.0.1", 8081);
}