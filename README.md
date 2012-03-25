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
  
      CrimsonModule sampleModule = new CrimsonModule(server);
      sampleModule.handlers
                    .addEndpoint(new Favicon("./favicon.ico"))               //match the favicon request
                    .addFilter(new CookieSession())                          //adds session support
                    .addEndpoint(new Route("/hello","GET",(req,res,data) {   //execute arbitary code that matches a route
					   res.outputStream.write("Hello");
					))         
                    .addEndpoint(new StaticFile("./public"));                //serve static files
  
      server.modules["*"] = sampleModule;  //this is the default module.
   
      server.listen("127.0.0.1", 8082);
     
    }
	
	

	
#TODO
* Lots, especially tidy up CookieSession and StaticFile, and add Route.
* Please treat all of this as pre-alpha.  
* It's not secure in the slightest, and the StaticFile handler alone will probably allow users to browse your pc!


#Filters
* CookieSession: sets a sessioncookie - just ported at the moment and not yet tested.  Treat as pre-alpha.

#Endpoints
* Favicon: Serves a favicon from either the default ./favicon.ico or ./public/favicon.ico, or some specified location.
* StaticFile: serves static files from the path provided in the constructor.  Simply appends the request.uri onto whatever path you provide in, and tries to load it.  Very insecure. 
* Route: executes a dart method in resposne to matching a path + method