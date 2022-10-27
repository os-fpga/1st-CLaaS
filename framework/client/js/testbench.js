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

var res1, res2;
let usernames = [];
let passwords = [];

function readURLOne(input) {
  if (input.files && input.files[0]) {

    var reader = new FileReader();

    reader.onload = function(e) {
      $('.image-upload-wrap-one').hide();

      $('#file-upload-image-one').attr('src', e.target.result);
      $('#file-upload-content-one').show();
      $('#image-title-one').html(input.files[0].name);

      console.log(reader.result)

      res1 = reader.result

      
    };

    // reader.readAsDataURL(input.files[0]);
    reader.readAsText(input.files[0]);

  } else {
    removeUploadOne();
  }
}

function removeUploadOne() {
  $('.file-upload-input-one').replaceWith($('.file-upload-input-one').clone());
  $('#file-upload-content-one').hide();
  $('.image-upload-wrap-one').show();
}
$('.image-upload-wrap-one').bind('dragover', function () {
        $('.image-upload-wrap-one').addClass('image-dropping-one');
    });
    $('.image-upload-wrap-one').bind('dragleave', function () {
       $('.image-upload-wrap-one').removeClass('image-dropping-one');
});


function readURLTwo(input) {
  if (input.files && input.files[0]) {

    var reader = new FileReader();

    reader.onload = function(e) {
      $('.image-upload-wrap-two').hide();

      $('#file-upload-image-two').attr('src', e.target.result);
      $('#file-upload-content-two').show();
      $('#image-title-two').html(input.files[0].name);

      console.log(reader.result)

      res2 = reader.result
    };

    // reader.readAsDataURL(input.files[0]);
    reader.readAsText(input.files[0]);

  } else {
    removeUploadTwo();
  }
}

function removeUploadTwo() {
  $('.file-upload-input-two').replaceWith($('.file-upload-input-two').clone());
  $('#file-upload-content-two').hide();
  $('.image-upload-wrap-two').show();
}
$('.image-upload-wrap-two').bind('dragover', function () {
        $('.image-upload-wrap-two').addClass('image-dropping-two');
    });
    $('.image-upload-wrap-two').bind('dragleave', function () {
        $('.image-upload-wrap-two').removeClass('image-dropping-two');
});

// Main
$(document).ready(function () {
  new RawTestBench();
});

class RawTestBench {
  constructor () {
    // Member Variables:
    this.tracing = false;
    this.server = new fpgaServer();
    this.server.connect();

    this.tx_data_array = null;
    this.tx_data_valid = false;

    // Attach handlers.

    this.server.ws.onmessage = (msg) => {
      console.log('yooooooo: ')
      
      try {

        console.log('Start')
        console.log(jsonstr)

        // myArray = jsonstr.split("");

        // console.log(myArray)
        // console.log(typeof(myArray))

        $("#rx-data-result").text("Result:");
        $("#rx-data").text(jsonstr[0]['data']);


        let data = JSON.parse(msg.data);
        
        console.log('Data: ', data)
        if (data.hasOwnProperty('type')) {
          
          this.log(`Received message: ${data.type}`);
        } else {
          
          this.receiveData(msg);
        }
      } catch(err) {
        
        this.log(`Failed to parse returned json string: ${msg.data}`);
      }
    }

    $("#send-button").click( (evt) => {
      this.sendData();
    });

  
  }
  sendData() {
    console.log("resses", [res1.split(" "), res2.split(" ")])
    this.server.sendChunks(2, [res1.split(" "), res2.split(" ")]);


    // this.server.sendChunks(0, [res2.split(" ")]);
  }

  receiveData(msg) {
    // Translate msg to hex.
    try {
      console.log('yoyoyo: ', msg.data)
      let data = JSON.parse(msg.data);
      console.log('Data: ', data)
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

function signup(){
  let signup = document.getElementById("signup");
  let signin = document.getElementById("signin");
  signup.style.display = "block";
  signin.style.display = "none";
}

function validate(){
  let home = document.getElementById("home");
  let signin = document.getElementById("signin");
  home.style.display = "block";
  signin.style.display = "none";
}

function validate_signup(){
  let signup = document.getElementById("signup");
  let signin = document.getElementById("signin");
  signup.style.display = "none";
  signin.style.display = "block";
}

function signout(){
  let home = document.getElementById("home");
  let signin = document.getElementById("signin");
  home.style.display = "none";
  signin.style.display = "block";
}
