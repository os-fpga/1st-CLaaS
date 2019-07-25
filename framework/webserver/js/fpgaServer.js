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
    this.f1_state = "stopped";
    this.f1_ip = false;
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
  
  
  // Feed the EC2 instance, and, optionally, callback upon response. The callback is passed the response JSON.
  feedEC2Instance(fed_cb) {
    $.ajax({
      url: '/feed_ec2_instance',
      type: 'get',
      success: (data, status, xhr) => {
        let json = "{}";
        try {
          json = JSON.parse(data);
        } catch(e) {
          json = {message: `Bad JSON response to feed_ec2_instance: ${json}`};
        }
        console.log("feed_ec2_instance response: " + json);
        if (json.message) {
          $("#fpga-message").text(json.message);
        }
        if (fed_cb) {
          fed_cb(json);
        }
      }
    });
  }
  
  // Begin feeding the EC2 instance. this.f1_state must be "running" or "pending", and this method does not perform
  // the initial feeding. This should be called, followed by another action which feeds (like a start_ec2_instance AJAX request).
  beginEC2Feeding() {
    // Schedule the next feeding, continuing as long as state is "running" or "pending".
    this.feeder_active = false;
    let scheduleEC2Feeding = () => {
      window.setTimeout( () => {
        console.log("Feeding.");
        if (this.f1_state == "running" || this.f1_state == "pending") {
          this.feeder_active = true;
          this.feedEC2Instance();
          scheduleEC2Feeding();
        } else {
          this.feeder_active = false;
        }
      }, this.feeding_period * 1000);
    }
    
    if (this.f1_state != "running" && this.f1_state != "pending") {
      console.log("Bug: Starting feeding when f1_state is: " + this.f1_state);
    }
    if (!this.feeder_active) {
      this.feeder_active = true;
      scheduleEC2Feeding();
    }
  }
  
  // Support for controls to start/stop an FPGA.
  // Server can enable listening to:
  //   /start_fpga (POST): Start FPGA, and return JSON of the form: {"ip": "...", "message": "..."}.
  // HTML should contain:
  //   <form id="start-fpga-form">
  //     Password: <input type="password" name="pwd">
  //     <input type="submit" value="Power On">
  //   </form>
  //   <button id="stop-fpga-button" class="btn btn-primary">Stop FPGA</button>
  //   <p id="fpga-message"><p>
  // This method attaches callbacks to:
  //   #start-fpga-form
  //   #stop-fpga-button
  // And populates:
  //   #fpga-message and
  // on ajaxComplete (if they exist).
  //
  // Args:
  //   feeding_period: Period between feedings in seconds.
  
  // Mimic EC2 F1 instance state as defined by the EC2 lifecycle.
  // Instance is static, so states cycle among: "stopped", "pending", "running", "stopping" (or "unknown").
  f1StateCB() {}  // A callback for f1 state change that can be overridden.
  set f1_state(val) {
    let els = $("ec2-instance-status");
    if (els.length > 0) {
      els[0].status = val;
    }
    this.f1StateCB();
  }
  get f1_state() {
    let els = $("ec2-instance-status");
    if (els.length > 0) {
      return $("ec2-instance-status")[0].status;
    } else {
      return "unknown";
    }
  }
  enableFPGAStartStop(feeding_period) {
    if (feeding_period) {
      this.feeding_period = feeding_period;
    } else {
      this.feeding_period = 60;  // 1 min default.
    }
    $('#start-fpga-form').submit( (e) => {
      e.preventDefault();
      this.f1_state = "pending";
      $("#start-fpga-button").prop("disabled", true);
      $("#fpga-message").text("Starting...");
      this.beginEC2Feeding();
      
      // Handle any failing cases for starting F1.
      let startFailed = (msg) => {
        // Go to "stopped" state.
        // This will cause feeding to stop in time.
        this.f1_state = "stopped";
        $("#start-fpga-button").prop("disabled", false);
        $("#fpga-message").text(`Start failed with: ${msg}`);
      }
      $.ajax({
        url: '/start_ec2_instance',
        type: 'post',
        data: $('#start-fpga-form').serialize(),
        success: (data, status, xhr) => {
          let json = "{}";
          try {
            json = JSON.parse(data);
          } catch(e) {
            json = {message: `Bad JSON response to start_ec2_instance: ${json}`};
          }
          console.log("start_ec2_instance response: " + json);
          if (json.message) {
            $("#fpga-message").text(json.message);
          }
          if (typeof json.ip === "undefined") {
            startFailed("malformed response");
          } else {
            // Good response.
            // Ping webserver until it responds, then start using this server.
            let ping = (cnt, timeout_ms) => {
              let jqxhr = $.get(`http://${json.ip}/ip`, (resp) => {
                // Success. Use this server.
                if (resp != json.ip) {
                  console.log(`Ping response should be IP (${json.ip}), but it is ${resp}. Continuing anyway.`);
                } else {
                  console.log(`Server at ${json.ip} is operational.`);
                }
                $('#stop-fpga-button').prop("disabled", false);
                this.f1_ip = json.ip;
                this.f1_state = "running";
              }).fail( () => {
                // Web server isn't running yet (presumably).
                if (cnt > 0) {
                  // Try again.
                  console.log(`Still waiting for webserver at json.ip... (${cnt})`);
                  window.setTimeout( () => {
                    ping(cnt - 1, timeout_ms);
                  }, timeout_ms);
                } else {
                  // Give up.
                  startFailed("Instance started, but web server never came up.");
                }
              })
            };
            ping(40, 4000);
          }
        },
        error: (xhr, status, e) => {
          startFailed("AJAX request error.");
        }
      });
    });
    $("#stop-fpga-button").click( () => {
      // Go straight to "stopped" state.
      // This will cause feeding to stop in time.
      this.f1_state = "stopped";
      $("#stop-fpga-button").prop("disabled", true);
      $('#start-fpga-button').prop("disabled", false);
    });
  }
  
}