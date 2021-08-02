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




// Main
$(document).ready(function () {
  new WARPV_Example();
});

class WARPV_Example {
  constructor () {
    // Constants:
    // The FPGA interface. The first word of the first chunk identifies the packet type.
    // To keep it simple, there is a response chunk for every chunk sent.
    // Each type shows send format, then receive format.
    this.IMEM_WRITE_TYPE = 1;  // {type, addr(instr-granular), data, ...} => {type, addr(instr-granular), data, ...}
    this.IMEM_READ_TYPE = 2;   // {type, addr, ...} => {type, addr, data, ...}
    this.RUN_TYPE = 4;         // {type, ...} => {type, CSR_CLAASRSP value, ...}

    this.IMEM_SIZE = 16;       // Number of entries/instructions in IMem.

    this.BEGIN_PROGRAM_LINE = "/* BEGIN PROGRAM";
    this.END_PROGRAM_LINE = "END_PROGRAM */";
    this.SV_BASE_CHARS = {b: 2, d: 10, h: 16};
    // Member Variables:
    this.tracing = false;
    this.server = new fpgaServer();
    this.server.connect({onopen: function () {console.log("hi");}, onclose: function () {console.log("closed");}, onerror: function () {console.log("error");}});

    this.source_instrs = null;  // An array for the parsed source code, where each entry is an extracted instruction as a parenthetical expression.


    // Process responses from FPGA.
    this.server.ws.onmessage = (msg) => {
      try {
        let data = JSON.parse(msg.data);
        if (data.hasOwnProperty('type')) {
          this.log(`Received message: ${data.type}`);
        } else {
          let chunk_type = data[0][0];
          if (chunk_type == this.IMEM_WRITE_TYPE) {
            this.receiveWriteResponse(data);
          }
          else if (chunk_type == this.IMEM_READ_TYPE) {
            this.receiveReadResponse(data);
          }
          else if (chunk_type == this.RUN_TYPE) {
            let rsp = data[0][1];
            console.log(`Received response for type ${chunk_type} with CSR value: ${rsp}.`);
            $("#warpv-rsp").text(`${rsp}`);
          }
          else {
            this.log(`Illegal chunk type: ${chunk_type}`);
          }
        }
      } catch(err) {
        this.log(`Failed to parse returned json string: ${msg.data}`);
      }
    }

    $('#run-button').click( (evt) => {
      // Disable button until assembly completes.
      $('#run-button').prop("disabled", true);
      $('#assembler-error-message').text('');
      $('#assembled-code').html('');
      $('#rx-data').text('');
      $("#warpv-rsp").text("-");
      this.assemble();

      $.ajax({
        type: "POST",
        url: 'http://saas.makerchip.com/sandpiper/json',
        data: { tlv: JSON.stringify( {"!top.tlv": this.tlv} ) },
        //contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: (response) => {
          // Process SandPiper output to extract assembled data.
          let chunks = this.verilogToChunks(response["top.m4out.tlv"]);
          // Send assembled binary to FPGA.
          this.server.sendChunks(chunks.length, chunks);
          // Send read commands to server to read each instruction from IMem.
          this.readIMem();
          // Send command to run WARP-V core.
          this.runWARPV();
        },
        error: (response) => {
          this.log('Error calling SandPiper(TM) SaaS');
        },
        complete: () => {
          // Done assembly.
          // Re-enable button.
          $('#run-button').prop("disabled", false);
        }
      });
    });

    $("#warpv-url").val("https://raw.githubusercontent.com/stevehoover/warp-v_includes/5100bc4424dd272ffd495dcb7d9653fb6b200e88/risc-v_defs.tlv");

    $("#assembly-code").val(
`
// /=====================\\
// | Count to 10 Program |
// \\=====================/
//

// Add 1,2,3,...,10 (in that order).
// Store incremental results in memory locations 0..9. (1, 3, 6, 10, ...)
//
// Regs:
// 1: cnt
// 2: ten
// 3: out
// 4: tmp
// 5: offset
// 6: store addr

(ORI,  r6, r0, 0)             //     store_addr = 0
(ORI,  r1, r0, 1)             //     cnt = 1
(ORI,  r2, r0, 1010)          //     ten = 10
(ORI,  r3, r0, 0)             //     out = 0
(ADD,  r3, r1, r3)            //  -> out += cnt
(SW,   r6, r3, 0)             //     store out at store_addr
(ADDI, r1, r1, 1)             //     cnt ++
(ADDI, r6, r6, 100)           //     store_addr++
(BLT,  r1, r2, 1111111110000) //  ^- branch back if cnt < 10
(LW,   r4, r6,  111111111100) //     load the final value into tmp
(CSRRW,r0, r4,  110000000000) // TERMINATE by writing CSR CLAASRSP
(BGE,  r1, r2, 1111111010000) // TERMINATE by branching to -1
`
    );

    $('#trace-button').click( (evt) => {
      if (this.tracing) {
        this.tracing = false;
        this.server.stopTracing();
        $('#trace-button').text("Trace On");
      } else {
        this.tracing = true;
        this.server.startTracing();
        $('#trace-button').text("Trace Off");
      }
    });
  }

  assemble() {
    // Parse source code to extract instructions--lines starting with a paranthetical expression that is the args for m4_asm.
    let source_lines = $("#assembly-code").val().split("\n");
    this.source_instrs = [];
    for (let i = 0; i < source_lines.length; i++) {
      let m = /^(\([^\)]*\))/.exec(source_lines[i]);
      if (m) {
        this.source_instrs.push(m[1]);
      }
    }


    this.tlv =
`\\m4_TLV_version 1d: tl-x.org
\\SV
m4_include_lib(['${$("#warpv-url").val()}'])

// TODO: This is likely to change in revisions of WARP-V, and there's no automation to check it.
m4+definitions(['
   m4_define_vector(['M4_WORD'], 32)
   m4_define(['M4_EXT_I'], 1)

   m4_define(['M4_NUM_INSTRS'], 0)   // TODO: Delete when using next rev of risc-v_defs.tlv.
   m4_echo(m4tlv_riscv_gen__body())
'])

// =============
// Assembly Code
// =============
m4_asm${this.source_instrs.join("\nm4_asm")}

// The syntax below will be parsed to find the program.
${this.BEGIN_PROGRAM_LINE}
m4_instr0['']m4_forloop(['m4_instr_ind'], 1, M4_NUM_INSTRS, ['m4_new_line()m4_echo(['m4_instr']m4_instr_ind)'])
${this.END_PROGRAM_LINE}
`;
    //console.log(this.tlv);
  }

  // Process the top.vs content into chunks to send to the FPGA.
  verilogToChunks(verilog) {
    let instr_cnt = 0;
    let assemblerError = function(msg) {
      $('#assembler-error-message').text(`Instr ${instr_cnt}: ${msg}`);
    }
    var ret = [];
    let verilog_lines = verilog.split("\n");
    let line;
    let i = 0;
    do {
      line = verilog_lines[i];
      i++;
      if (i >= verilog_lines.length) {
        assemblerError("Parse error: Failed to find begining of program.");
        return ret;
      }
    } while (line != this.BEGIN_PROGRAM_LINE);
    let assembly_debug = "";
    do {
      line = verilog_lines[i];
      if (line == this.END_PROGRAM_LINE) {break;}

      // Process line, pushing a single-value array onto ret.
      let value32 = 0;  // The value of the SV expression.
      let error = false;
      try {
        let num_bits = 0;  // The number of bits processed so far (right-to-left).
        // Line must be: {<verilog constant>, ...}
        let m = /^{(.*)}$/.exec(line);
        if (!m) {
          debugger;
          throw new Error(`Failed to parse: ${line}.`);
        }
        let sv_consts = m[1].split(',');
        let sv_const;
        while (sv_const = sv_consts.pop()) {
          let m = /^\s*(\d+)'(\w)(\w+)\s*$/.exec(sv_const);
          if (!m) {
            debugger;
            throw new Error(`Failed to parse Verilog constant expression: ${sv_consts[sv_consts.length - 1]}`);
          }
          let bits = parseInt(m[1]);
          let base = this.SV_BASE_CHARS[m[2]];
          let digits = m[3];
          let val = 0;  // Value of this constant expression.
          let place_value = 1;  // Value multiplier for this digit.
          for (let dig = 0; dig < digits.length; dig++) {
            let code = digits.charCodeAt(digits.length-1-dig);
            let num_code = code - "0".charCodeAt(0);
            let lower_alpha_code = code - "a".charCodeAt(0) + 10;
            let upper_alpha_code = code - "A".charCodeAt(0) + 10;
            let char_val = (num_code >= 0 && num_code < 10)                  ? num_code :
                           (lower_alpha_code >= 10 && lower_alpha_code < 16) ? lower_alpha_code :
                           (upper_alpha_code >= 10 && upper_alpha_code < 16) ? upper_alpha_code :
                                                                               -1;
            if (char_val < 0 || char_val > base) {
              throw new Error(`Illegal digit "${digits[digits.length-1-dig]}" in ${sv_const}`);
            }
            val += place_value * char_val;
            place_value *= base;
          }
          value32 += val * (num_bits == 31 ? 2147483648 : 1 << num_bits);  // (<< uses 32-bit signed math, so num_bits == 31 is a special case; multiplication is 64-bit floating point.)
          if (value32 < 0) {debugger;}
          num_bits += bits;
        }
        if (num_bits != 32) {
          throw new Error(`Assembled value does not contain 32 bits: ${line}`);
        }
        ret.push([this.IMEM_WRITE_TYPE, instr_cnt, value32]);
      } catch (e) {
        assemblerError(`Failed to parse assembled Verilog expressions with exception: ${e.message}`);
        error = true;
      }
      let instr_el = $(`<p id="debug-instr-${instr_cnt}" class="${error ? "error" : ""}"></p>`);
      instr_el.text(`${this.source_instrs[instr_cnt]}: ${line}: 32'h${value32.toString(16)}`);
      $("#assembled-code").append(instr_el);

      i++;
      instr_cnt++;
      if (i >= verilog_lines.length) {
        assemblerError("Parse error: Failed to find end of program.");
      }
    } while (i < verilog_lines.length && true);

    return ret;
  }

  readIMem() {
    let i;
    for (i = 0; i < this.IMEM_SIZE; i++) {
      this.server.sendChunks(1, [[this.IMEM_READ_TYPE, i]]);
    }
  }

  // Send command to run WARP-V.
  runWARPV() {
    this.server.sendChunks(1, [[this.RUN_TYPE]]);
  }

  sendData(data) {
    if (! this.tx_data_valid) {
      this.log("Bug: Refusing to send invalid data.");
    } else {
      let tmp = `{"size":${this.tx_data_array.length},"resp_size":${$("#num-resp-chunks").val()},"data":${JSON.stringify(this.tx_data_array)}}`;
      console.log(`Sending DATA_MSG: ${tmp}`);
      this.server.send("DATA_MSG", tmp);
    }
  }

  receiveWriteResponse(data) {
    // Translate msg to hex.
    try {
      let display_data = [];
      data.forEach( (chunk, i) => {
        let display_chunk = chunk.map( (val) => {return val.toString(16);} );
        display_data[i] = display_chunk;
      });
      $("#rx-data").text(JSON.stringify(display_data));
    } catch(err) {
      this.log(`Failed to display program load response.`);
    }
  }

  receiveReadResponse(data) {
    try {
      data = data[0];
      let addr = data[1];
      let el = $(`#imem > #instr${addr}`);
      if (el.length == 0) {
        $("#imem").append($(`<p id="instr${addr}"></p>`));
      }
      $(`#imem > #instr${addr}`).text(`32'h${data[2].toString(16)}`);
    } catch(err) {
      this.log(`Failed to process IMem read response.`);
    }
  }

  log(msg) {
    $("#message").text(msg);
  }
}
