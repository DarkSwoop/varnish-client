acl purge {
  "localhost";
}

sub vcl_recv {
  if (req.request == "PURGE") {
    if (!client.ip ~ purge) {
      error 405 "Not allowed.";
    }
    if (req.http.X-Varnish-Purge-Request == "all") {
      ban("req.url ~ " + req.url);
      error 200 "Ban added.";
    }
    if (req.http.X-Varnish-Purge-Request == "single") {
      ban("req.http.host == " + req.http.host + " && req.url ~ " + req.url);
      error 200 "Ban added.";
    }
    error 405 "Not allowed.";
  }
}


