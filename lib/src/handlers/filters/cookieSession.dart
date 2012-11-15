part of crimson_core;



/// [CookieSession] is a filter which adds a session object to the request
/// making it available to other calls.
class CookieSession implements CrimsonFilter {

  Logger logger;
  CrimsonHttpServer server;

  CookieSession() {
    logger = LoggerFactory.getLogger("CookieSession");
    _sessions = new Map<String,Session>();
  }

  Future<Map> handle(HttpRequest req, HttpResponse res, Map data) {
    Completer completer = new Completer();
    if (req.path.endsWith("favicon.ico")) {
      //don't do session checking for favicon
      return null;
    }

    Session session = _checkSession(req,res);
    if (session != null) {
      logger.debug("Got session");
      data["SESSION"] = session;
    }
    else {
      logger.debug("Did not get session");
    }
    return null;
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
  Session _getSession(HttpRequest req) {
    //TODO - CJB: Fix this - it's fragile.
    logger.debug("in _getSession");
    //tempcookie takes precdence, as it's been added.
    String cookieHeader = req.headers.value("tempcookie");
    if (cookieHeader == null) {
      //otherwise, look for a real cookie header.
      cookieHeader = req.headers.value("cookie");
      if (cookieHeader != null) {
        logger.debug("found real cookie header: $cookieHeader");
      }
      else {
        logger.debug("didn't find existing cookie header");
      }
    }
    else {
      logger.debug("tempCookieHeader=${cookieHeader}");
    }

    Session result = null;

    if (cookieHeader != null) {
      logger.debug("found cookie header, so attempting to exract");
      String sessionId = _extractSessionCookieId(cookieHeader);

      if (sessionId != null && _sessions.containsKey(sessionId) == true) {
        logger.debug("found sessionid=${sessionId} in sessions object");
        result = _sessions[sessionId];
      }
      else {
        logger.debug("sessionId=${sessionId} not found in sessions object");
        //so we'll return null in the result.
      }
    }


    return result;
  }

  /**
  *  Adds a session cookie
  */
  Session _checkSession(HttpRequest req, HttpResponse res) {
    String sessionid = null;
    bool addSessionCookie = false;


    //is there an existing session?
    Session session = _getSession(req);
    logger.debug("session is null?=${session==null}");

    if (session == null) {
      //TODO: Refactor
      logger.debug("adding session cookie");

      //is there an existing cookie header?
      //if so, re-use the session cookie id...
      String cookieHeader = req.headers.value("cookie");
      if (cookieHeader != null) {
        sessionid = _extractSessionCookieId(cookieHeader);
      }

      //if we can't extract the sessionId from the header...
      if (sessionid == null) {
        //generate a new ID.

        //this is a toy - don't use for real!
        var md5 = new MD5();
        String s = "FAIL"; //= (Math.random() * Clock.now()).toInt().toString();
        md5.update(s.charCodes);
        var hash = md5.digest();
        sessionid = new String.fromCharCodes(hash);
      }

      //add a new session cookie.
      //no expiry means it will go when the browser session ends.
      res.headers.add("Set-Cookie","${SESSION_COOKIE}=${sessionid}; Path=/;");

      //add it into the request, too, as this is used later by the getSession()
      //on the first pass, and it should take precedence over the cookie on the request.
      //TODO: change the cookie ID on the request.
      res.headers.set("tempcookie", "${SESSION_COOKIE}=${sessionid}; Path=/;");
      //create somewhere to store stuff and add to the list of sessions
      _sessions[sessionid] = session = new Session();

      //also store the session id in the session
      //this allows callers to get the session id.
      _sessions[sessionid]["session-id"] = sessionid;
      logger.debug("Created Session: ${sessionid}");

      //add the time the session was first created
      _sessions[sessionid]["first-accessed"] = new Date.now();

    }
    else {
      logger.debug("there is already a session cookie");
    }

    //add the time the last accessed the session (ie, now).
    logger.debug("session is null?=${session==null}");
    session["last-accessed"] = new Date.now();

    if (req.headers.value("cookie") != null) {
      logger.debug("Header: cookie=${req.headers['cookie']}");
    }

    return session;
  }

  Map<String,Session> _sessions;
  final String NAME = "CookieSession";
  final String SESSION_COOKIE = "sessioncookie";
}


