#library('crimsonTest');

#import("../core/CrimsonLib.dart");
#import("../handlers/HandlersLib.dart");
#import("dart:io");

///Simple test server
main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  CrimsonModule sampleModule = new CrimsonModule(server);
  sampleModule.handlers
                    .addEndpoint(new Favicon("./test/favicon.ico"))                   
                    .addFilter(new CookieSession())
                    .addEndpoint(new Route("/hello","GET",sayHello))
                    .addEndpoint(new Route.withMatcher(matcherFunction,"helloMatcher",sayHello))
                    .addEndpoint(new StaticFile("./test/public"));
  

  server.modules["*"] = sampleModule;
   
  server.listen("127.0.0.1", 8082);
}

bool matcherFunction(HttpRequest req) {
  return req.path.endsWith("matcher");
}

Future sayHello(HttpRequest req,HttpResponse res,var data) {
  res.outputStream.writeString("Hello");
  var session = data["SESSION"];
  if (session != null) {
    res.outputStream.writeString("\nFirst Visit: " + session["first-accessed"]);
    res.outputStream.writeString("\nMost recent Visit: " + session["last-accessed"]);
  }
  return null;  
}