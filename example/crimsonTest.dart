#library('crimsonTest');
#import("dart:io");
#import("dart:utf");

#import('package:log4dart/log4dart.dart');
#import('package:crimsonhttp/crimson.dart');

void main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  CrimsonModule sampleModule = new CrimsonModule(server);
  sampleModule.handlers
                    //.addEndpoint(new Route.withMatcher(matcherFunction,"helloMatcher",sayHello))
                    .addEndpoint(new Route("/buckshotbin","GET", getTemplateData))
                    .addEndpoint(new Route("/buckshotbin","POST", setTemplateData))
                    .addEndpoint(new StaticFile("./example/public/"))
                    .addEndpoint(new StaticFile("./example/sandbox/"));
  
  server.modules["*"] = sampleModule;
  server.listen("0.0.0.0", 8082);
}

Future getTemplateData(HttpRequest req,HttpResponse res,var data) {
  Completer c = new Completer();
  print("queryParameters= ${req.queryParameters}");
  print(data);
  res.outputStream.writeString("getTemplateData");
  c.complete(null);
  return c.future;  
}

Future setTemplateData(HttpRequest req,HttpResponse res,var data) {
  Completer c = new Completer();
  print(data);
  StringBuffer sb = new StringBuffer();
  
  req.inputStream.onData = () {
    print("setTemplateData onData");
    sb.add(decodeUtf8(req.inputStream.read(req.inputStream.available())));
  };
  
  req.inputStream.onClosed = () {
    print("setTemplateData onClose");
    print(sb.toString());
    
    res.outputStream.writeString(sb.toString());
    c.complete(null);
  };
  
  req.inputStream.onError = (e) {
    print("setTemplateData onError");
    print("error $e");
    c.complete(null);
  };
  
  return c.future;  
}

//bool matcherFunction(HttpRequest req) {
//  return req.path.endsWith("matcher");
//}