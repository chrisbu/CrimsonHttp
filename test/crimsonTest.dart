#library('crimsonTest');

#import("../crimson.dart");

main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  server.filters.add(null).add(null);
//  server.filters.add(handler)
//     .add(handler)
//     .add(handler);
  
  server.listen("127.0.0.1", 8080);
}