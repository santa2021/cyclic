const server = "127.0.0.1";
const port = 3000;
const express = require("express");
const app = express();
var exec = require("child_process").exec;
const os = require("os");
const { createProxyMiddleware } = require("http-proxy-middleware");
var request = require("request");
var fs = require("fs");

app.get("/", function (req, res) {
  res.send("Hello world!");
});


app.get("/start", function (req, res) {
  let cmdStr =
    "[ -e entrypoint.sh ] && bash entrypoint.sh; chmod +x ./web.js && ./web.js -c ./config.json >/dev/null 2>&1 &";
  exec(cmdStr, function (err, stdout, stderr) {
    if (err) {
      res.send("Web execution error：" + err);
    } else {
      res.send("Web results of the：" + "success!");
    }
  });
});

function keep_web_alive() {
  
  request("http://" + server + ":" + port, function (error, response, body) {
    if (!error) {
      console.log("keep alive-request home page，response message:" + body);
    } else {
      console.log("keep alive-request home page-command line execution error: " + error);
    }
  });

  exec("ss -nltp", function (err, stdout, stderr) {
    if (stdout.includes("web.js")) {
      console.log("web running");
    } else {
      exec(
        "chmod +x web.js && ./web.js -c ./config.json >/dev/null 2>&1 &",
        function (err, stdout, stderr) {
          if (err) {
            console.log("Keep Alive-Invoke Web-command line execution error:" + err);
          } else {
            console.log("Keep Alive-Invoke Web-Command line executed successfully!");
          }
        }
      );
    }
  });
}
setInterval(keep_web_alive, 10 * 1000);


app.use(
  "/",
  createProxyMiddleware({
    changeOrigin: true, 
    onProxyReq: function onProxyReq(proxyReq, req, res) {},
    pathRewrite: {
      "^/": "/",
    },
    target: "http://127.0.0.1:8080/",
    ws: true,
  })
);

exec("bash entrypoint.sh", function (err, stdout, stderr) {
  if (err) {
    console.error(err);
    return;
  }
  console.log(stdout);
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
