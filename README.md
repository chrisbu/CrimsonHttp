# CrimsonHttp server for Dart

## Introduction ## 

Loosely inspired upon sencha/connect for node.js

## Status: Alpha ##
This code is alpha and might not be safe for production servers.  

## Example ##

```
#import("dart:io");
#import("dart:utf");
#import('package:crimsonhttp/crimson.dart');

void main() {
  CrimsonHttpServer server = new CrimsonHttpServer();
  
  CrimsonModule sampleModule = new CrimsonModule(server);
  sampleModule.handlers
                    .addEndpoint(new StaticFile("./test/public/"))
                    .addEndpoint(new StaticFile("./test/sandbox/"));
  
  server.modules["*"] = sampleModule;
  server.listen("0.0.0.0", 8082);
}
```
	
# Getting Started
Create a Dart project and add a **pubspec.yaml** file to it

```
dependencies:
  crimsonhttp:
    git: https://github.com/chrisbu/CrimsonHttp.git
```

and run **pub install** to install **crimson** (including its dependencies). Now add import

```
#import('package:crimsonhttp/crimson.dart');
```

	
#TODO
* Lots, especially tidy up CookieSession and StaticFile, and add Route.
* Please treat all of this as pre-alpha.  
* It's not secure in the slightest, and the StaticFile handler alone will probably allow users to browse your pc!


#Filters
* CookieSession: sets a sessioncookie - just ported at the moment and not yet tested.  Treat as pre-alpha.

#Endpoints
* Favicon: Serves a favicon from either the default ./favicon.ico or ./public/favicon.ico, or some specified location.
* StaticFile: serves static files from the path provided in the constructor.  Simply appends the request.uri onto whatever path you provide in, and tries to load it.  Very insecure. 
* Route: executes a dart method in resposne to matching a path + method, or a matching function