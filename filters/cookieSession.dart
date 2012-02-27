


/// [CookieSession] is a filter which adds a session object to the request
/// making it available to other calls.
class CookieSession implements CrimsonFilter {

  CrimsonHttpServer server;
  
  void handle(CrimsonHttpRequest req, HTTPResponse res, void next(error)) {
    if (req.path.endsWith("favicon.ico")) {
      //don't do session checking for favicon
      return next(null);
    }
    
    Session session = _getSession(req);
    next(null);
  }
  
  
  /**
  * get the session cookie Id from the header.
  */
  _extractSessionCookieId(String cookieHeader) {
    //TODO: fragile
    List<String> cookies = cookieHeader.split(";");
    String sessionid = null;
    for (String cookie in cookies) {
      String key = cookie.split("=")[0];
      if (key.contains(SESSION_COOKIE)) {
        sessionid = cookie.split("=")[1];
        break;
      }
    }
    
    return sessionid;
    
  }
    
  /**
  * return the session associated with the request.
  */
  Session _getSession(HTTPRequest req) {
    //TODO - CJB: Fix this - it's fragile.
     
    //tempcookie takes precdence, as it's been added.
    String cookieHeader = req.headers["tempcookie"];
    if (cookieHeader == null) {
      //otherwise, look for a real cookie header.
      cookieHeader = req.headers["cookie"];
      if (cookieHeader != null) {
        print("found real cookie header: " + cookieHeader);
      }
    }
    else {
      print("tempCookieHeader=${cookieHeader}");
    }
     
    Session result = null;
     
    if (cookieHeader != null) {
      String sessionId = _extractSessionCookieId(cookieHeader);
       
      if (sessionId != null && _sessions.containsKey(sessionId) == true) {
        print("found sessionid=${sessionId} in sessions object");
        result = _sessions[sessionId];
      }
      else {
        print("sessionId=${sessionId} not found in sessions object");  
        //so we'll return null in the result.
      }
    }
     
     
    return result;
  }

  /**
  *  Adds a session cookie  
  */
  Session _checkSession(HTTPRequest req, HTTPResponse res) {
    String sessionid = null;
    bool addSessionCookie = false;
    
   
    //is there an existing session?
    Session session = _getSession(req);
    print("session is null?=${session==null}");
    
    if (session == null) {
      //TODO: Refactor
      print("adding session cookie");
      
      //is there an existing cookie header? 
      //if so, re-use the session cookie id...
      String cookieHeader = req.headers["cookie"];
      if (cookieHeader != null) {
        sessionid = _extractSessionCookieId(cookieHeader);
      }
        
      //if we can't extract the sessionId from the header...
      if (sessionid == null) {
        //generate a new ID.
        
        //this is a toy - don't use for real!
        sessionid = (Math.random() * Clock.now()).toInt().toString();    
      }

      //add a new session cookie.
      //no expiry means it will go when the browser session ends.
      res.setHeader("Set-Cookie","${SESSION_COOKIE}=${sessionid}; Path=/;");
      
      //add it into the request, too, as this is used later by the getSession() 
      //on the first pass, and it should take precedence over the cookie on the request.
      //TODO: change the cookie ID on the request. 
      req.headers.putIfAbsent("tempcookie", () => "${SESSION_COOKIE}=${sessionid}; Path=/;");
      //create somewhere to store stuff
      _sessions[sessionid] = new Map<String,Object>();
        
      //also store the session id in the session
      //this allows callers to get the session id.
      _sessions[sessionid]["session-id"] = sessionid; 
      print("Created Session: ${sessionid}");
        
      //add the time the session was first created
      _sessions[sessionid]["first-accessed"] = new Date.now();

    }
    else {
      print("there is already a session cookie");
    } 

    

    //add the time the last accessed the session (ie, now).
    session = _getSession(req);
    session["last-accessed"] = new Date.now(); 
      
    if (req.headers.containsKey("cookie")) {
      print("Header: cookie=${req.headers['cookie']}");
    }
    
    return session;
  }
  
  Map<String,Session> _sessions;
  final String NAME = "CookieSession";
  final String SESSION_COOKIE = "sessioncookie";
}


