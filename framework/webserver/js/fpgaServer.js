class fpgaServer {
  
  constructor() {
    this.host = location.hostname;
    this.port = location.port;
    this.url_path = "/ws";
  }
  
  connect() {
    this.ws = new WebSocket("ws://" + this.host + ":" + this.port + this.url_path);
  }
  
  connectTo(host, port = 80, url_path = "/ws") {
    this.host = host;
    this.port = port;
    this.url_path = url_path;
    this.connect();
  }
  
  send(type, obj) {
    // Prevent the user from using types reserved by the framework.
    if (typeof type === "string" && type.startsWith("~")) {
      console.log(`Refusing to send to FPGA using type "${type}" which is reserved by the framework.`);
    } else {
      // Wrap user object as expected by FPGA server.
      obj = { "type": type, "payload": obj };
      this.ws.send(JSON.stringify(obj));
    }
  }
  
}