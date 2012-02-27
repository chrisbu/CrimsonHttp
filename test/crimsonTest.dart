#library('crimsonTest');

#import("../crimson.dart");
#import("../filters/filters.dart");
#import("../endpoints/endpoints.dart");


///Simple test server
main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  server.filters
      .add(new CookieSession());
  server.endpoints
      .add(new Favicon())
      .add(new StaticFile("./public"));
  
  server.listen("127.0.0.1", 8082);
}