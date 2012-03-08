#library('crimsonTest');

#import("../crimson.dart");



///Simple test server
main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  server.filters
      .add(new CookieSession());
  server.endpoints
      .add(new Favicon("./test/favicon.ico"))
      .add(new StaticFile("./test/public"));
  
  server.listen("127.0.0.1", 8082);
}