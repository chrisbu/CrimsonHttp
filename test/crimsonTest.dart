#library('crimsonTest');

#import("../core/crimson.dart");
#import("../handlers/handlers.dart");
#import("dart:io");

///Simple test server
main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  CrimsonModule sampleModule = new CrimsonModule(server);
  sampleModule.handlers
                    .addEndpoint(new Favicon("./favicon.ico"))                   
                    .addFilter(new CookieSession())
                    .addEndpoint(new Route("/hello","GET",sayHello))
                    .addEndpoint(new StaticFile("./public"));
  

  server.modules["*"] = sampleModule;
   
  server.listen("127.0.0.1", 8082);
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