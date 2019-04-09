// BSD 3-Clause License
// 
// Copyright (c) 2018, alessandrocomodi
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// 
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// * Neither the name of the copyright holder nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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