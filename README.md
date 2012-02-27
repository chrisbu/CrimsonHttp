CrimsonHttp server for Dart
----------

Currently uses the chat sample http server, but will be ported to the 
dart:io http server once that is released

Loosely inspired upon sencha/connect for node.js

Makes use of log4dart, found here: https://github.com/Qalqo/log4dart

-----
Usage: See test/crimsonTest.dart for example, but it goes something like this...

    main() {
     CrimsonHttpServer server = new CrimsonHttpServer();
  
     server.filters.add(new CookieSession())
	          .add(otherFilter)
			  .add(someOtherFilter)
			  .add(etc);
     server.endpoints.add(new Favicon())
			  .add(new StaticFiles("./public/"))
			  .add(new Route("/customers", onCustomersRoute(req,res))
			  .add(new Route("/other", onOtherRoute(req,res));
  
     server.listen("127.0.0.1", 8082);
    }
	
#TODO
- The only thing currently working is the logger and the favicon filter


Filters
- Lots todo

Endpoints
- Favicon: Serves a favicon from either the default ./favicon.ico or ./public/favicon.ico, or some specified location.