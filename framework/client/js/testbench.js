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


// This file contains content to help develop webpage test benches for apps.


// Main
$(document).ready(function () {
  new RawTestBench();
});

class RawTestBench {
  constructor () {
    // Member Variables:
    this.server = new fpgaServer();
    this.server.connect();

    this.tx_data_array = null;
    this.tx_data_valid = false;

    // Attach handlers.

    this.server.ws.onmessage = (msg) => {
      this.receiveData(msg);
    }

    $("#tx-data-js").change( (evt) => {
      this.parseTxData();
    });
    $("#num-resp-chunks").change( (evt) => {
      this.parseTxData();
    });

    $("#send-button").click( (evt) => {
      this.sendData();
    });


    $("#tx-data-js").val(
`{default_int: parseInt('55555555', 16),
 high_int: parseInt('12345678', 16),
 low_int: parseInt('04030201', 16)
}`
    );
    $("#tx-data-js").change();
    $("#num-resp-chunks").change();
  }

  parseTxData() {
    // Parse Tx Data.
    let txt = $("#tx-data-js").val();
    this.tx_data_array = null;
    this.tx_data_valid = false;
    $("#send-button").prop("disabled", true);
    let exp_num_resp_chunks = 0;  // Incremented for each expected output chunk.
    try {
      this.tx_data_array = eval(`[${txt}]`);
      // Interpret as integer arrays.
      this.tx_data_array = this.tx_data_array.map( (val) => {
        let ret = [];
        for (let i=0; i < 16; i++) {
          ret[i] = val.default_int;
        }
        if (typeof val.high_int !== "undefined") {
          ret[15] = val.high_int;
        }
        if (typeof val.low_int !== "undefined") {
          ret[0] = val.low_int;
        }

        // For checking data consistency with #num-resp-chunks
        // under the assumption that the kernel will produce a number of output chunks equal to the low byte of the input data.
        exp_num_resp_chunks += ret[0] % 256;

        return ret;
      });
      this.tx_data_valid = true;
      $("#send-button").prop("disabled", false);
    } catch(err) {
      $("#message").text("Failed to parse Tx Data:" + err);
    }

    $("#num-resp-chunks").css("background-color", (parseInt($("#num-resp-chunks").val()) == exp_num_resp_chunks) ? "white" : "red");
  }

  sendData() {
    if (! this.tx_data_valid) {
      console.log("Bug: Refusing to send invalid data.");
    } else {
      let tmp = `{"size":${this.tx_data_array.length},"resp_size":${$("#num-resp-chunks").val()},"data":${JSON.stringify(this.tx_data_array)}}`;
      console.log(`Sending DATA_MSG: ${tmp}`);
      this.server.send("DATA_MSG", tmp);
    }
  }

  receiveData(msg) {
    // Translate msg to hex.
    try {
      let data = JSON.parse(msg.data);
      let display_data = [];
      data.forEach( (chunk, i) => {
        let display_chunk = chunk.map( (val) => {return val.toString(16);} );
        display_data[i] = display_chunk;
      });
      $("#rx-data").text(JSON.stringify(display_data));
    } catch(err) {
      $("#message").text(`Failed to parse returned json string: ${msg.data}`);
    }
  }
}
