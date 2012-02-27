CrimsonHttp server for Dart
----------

Currently uses the chat sample http server, but will be ported to the 
dart:io http server once that is released

Loosely inspired upon sencha/connect for node.js

Makes use of log4dart, found here: https://github.com/Qalqo/log4dart
(It expects to find log4dart in ../log4dart (ie, at the same level as crimson, not within the 
crimson folder structure).

-----
Usage: See test/crimsonTest.dart for example, but it goes something like this...

    main() {
     CrimsonHttpServer server = new CrimsonHttpServer();
  
     // optional - this is created internally in the CrimsonHttpServer ctor
	 // but you can override it here.
	 // server.logger = LoggerFactory.getLogger("crimson");
  
     //Add any filters that you might be interested in
     server.filters.add(new CookieSession())               //DONE but fragile and insecure
	          .add(otherFilter)                            //examples
			  .add(someOtherFilter)
			  .add(etc);
     server.endpoints.add(new Favicon())                               //DONE
			  .add(new StaticFile("./public/"))                        //DONE
			  .add(new Route("/customers", onCustomersRoute(req,res))  //TODO
			  .add(new Route("/other", onOtherRoute(req,res))          //TODO
			  .add(etc);           //Examples
  
     server.listen("127.0.0.1", 8082);
    }
	
	

	
#TODO
- The only thing currently working is the logger and the favicon filter


Filters
- Lots todo

Endpoints
- Favicon: Serves a favicon from either the default ./favicon.ico or ./public/favicon.ico, or some specified location.