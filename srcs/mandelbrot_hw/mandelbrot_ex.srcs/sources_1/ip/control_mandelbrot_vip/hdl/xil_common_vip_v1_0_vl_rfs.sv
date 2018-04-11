//  (c) Copyright 2016 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES. 
`timescale 1ps/1ps

`include "xil_common_vip_v1_0_0_macros.svh"
package xil_common_vip_v1_0_0_pkg;

// unsigned integer: xil_verbosity
// Specifies the policy for how much debug information to produce.
// XIL_VERBOSITY_NONE      - No information will be shown.
// XIL_VERBOSITY_FULL      - All information will be shown.
typedef integer unsigned           xil_uint;
typedef xil_uint                   xil_verbosity;
parameter                          XIL_VERBOSITY_NONE =0;
parameter                          XIL_VERBOSITY_FULL =400;

typedef struct {
  int    level;
  string name;
  string type_name;
  string size;
  string val;
} xil_printer_row_info;

parameter XIL_STREAMBITS = 4096;
typedef logic signed [XIL_STREAMBITS-1:0] xil_bitstream_t;
typedef logic signed [63:0] xil_integral_t;

class xil_void;
endclass: xil_void

typedef class xil_printer;
typedef class xil_table_printer;

class xil_object extends xil_void;
  xil_table_printer         xil_default_table_printer = new();
  xil_printer               printer;
  protected xil_verbosity   verbosity = XIL_VERBOSITY_NONE;
  protected bit             is_active = 0;
  protected string          TAG ="xil_object";
  string                    name = "unnamed_object";
  local int                 m_inst_id;
  static protected int      m_inst_count;
  xil_object                object;
  bit                       cycle_check[xil_object];
  protected bit             stop_triggered_event = 0;
  
  function new (input string name = "");
    this.name = name;
    m_inst_id = m_inst_count++;
    this.stop_triggered_event = 0;
    this.is_active = 0;
  endfunction

// function get_name
  function string get_name();
    return(this.name);
  endfunction: get_name

// function get_full_name 
  function string get_full_name();
    return get_name();
  endfunction :get_full_name

// function set_name
  function void set_name(input string n);
    this.name = n;
  endfunction: set_name

//function get_inst_id
  function int get_inst_id();
    return m_inst_id;
  endfunction : get_inst_id

//function get_type_name
  virtual function string get_type_name ();
    return "<unknown>";
  endfunction : get_type_name

//function do_sprint
  virtual function void do_print(xil_printer printer);
  endfunction: do_print

//function sprint
  virtual function string sprint(xil_printer printer=null);
    if(printer==null)
      printer = xil_default_table_printer;
    // not at top-level, must be recursing into sub-object
    if(!printer.istop()) begin
      do_print(printer);
      return "";
    end
    printer.print_object(get_name(), this);
    if (printer.m_string != "")
      return printer.m_string;
    return printer.emit();
  endfunction

  virtual function bit do_compare(xil_object rhs);
    return(1);
  endfunction: do_compare

  /*
    Function: set_verbosity
    Sets the amount of debug information will be printed.
  */
  virtual function void set_verbosity(xil_verbosity updated);
    this.verbosity = updated;
  endfunction : set_verbosity

  /*
    Function: get_verbosity
    Returns the current value of the verbosity.
  */
  virtual function xil_verbosity get_verbosity();
    return(this.verbosity);
  endfunction : get_verbosity

  /*
    Function: set_tag
    Sets the name/TAG of the object
  */
  virtual function void set_tag(input string value);
    this.TAG = value;
  endfunction : set_tag

  /*
    Function: get_tag
    Gets the name/TAG of the object
  */
  virtual function string get_tag();
    return(this.TAG); 
  endfunction : get_tag

  /*
    Function: set_is_active
    Sets the active state of the object
  */
  virtual function void set_is_active();
    this.is_active = 1;
  endfunction : set_is_active

  /*
    Function: clr_is_active
    Clears the active state of the object
  */
  virtual function void clr_is_active();
    this.is_active = 0;
  endfunction : clr_is_active

  /*
    Function: get_is_active
    Returns the is_active value of the object. A value of 1 is considered active.
  */
  virtual function bit get_is_active();
    return(this.is_active); 
  endfunction : get_is_active
 
  /*
   Function: wait_enabled
   Wait until is_active is high
  */
  task wait_enabled();
    wait(this.is_active == 1);
  endtask : wait_enabled
endclass : xil_object

typedef class xil_component;

//----------------------------------------------------------------------------
// CLASS- xil_scope_stack
//----------------------------------------------------------------------------

class xil_scope_stack;
  local string              m_arg;
  local string              m_stack[$];
  // depth 
  function int depth();
    return m_stack.size();
  endfunction
  
  // scope
  function string get();
    string v;
    if(m_stack.size() == 0) return m_arg;
    get = m_stack[0];
    for(int i=1; i<m_stack.size(); ++i) begin
      v = m_stack[i];
      if(v != "" && (v[0] == "[" || v[0] == "(" || v[0] == "{"))
        get = {get,v};
      else
        get = {get,".",v};
    end
    if(m_arg != "") begin
      if(get != "")
        get = {get, ".", m_arg};
      else
        get = m_arg;
    end
  endfunction
  
  // down
  function void down (string s);
    m_stack.push_back(s);
    m_arg = "";
  endfunction
  
  // up
  function void up (byte separator =".");
    bit found;
    string s;
    while(m_stack.size() && !found ) begin
      s = m_stack.pop_back();
      if(separator == ".") begin
        if (s == "" || (s[0] != "[" && s[0] != "(" && s[0] != "{"))
          found = 1;
      end
      else begin
        if(s != "" && s[0] == separator)
          found = 1;
      end
    end
    m_arg = "";
  endfunction
  
  // set_arg
  function void set_arg (string arg);
    if(arg=="") return;
    m_arg = arg;
  endfunction
  
endclass  :xil_scope_stack 

// Class: xil_printer
 virtual class xil_printer;
  // Variable: header
  // Indicates whether the <xil_printer::format_header> function should be called when
  // printing an object.
  bit                       header = 1;
  // Variable: full_name
  // Indicates whether <xil_printer::adjust_name> should print the full name of an identifier
  // or just the leaf name.
  bit                       full_name = 0;
  // Variable: type_name
  // Controls whether to print a field's type name. 
  bit                       type_name = 1;
  // Variable: size
  // Controls whether to print a field's size. 
  bit                       size = 1;
  // Variable: indent
  // This knob specifies the number of spaces to use for level indentation. 
  // The default level indentation is two spaces.
  int                       indent = 2;
  protected bit             m_array_stack[$];
  xil_scope_stack           m_scope = new;
  string                    m_string;
  // holds each cell entry
  protected xil_printer_row_info m_rows[$];
  // Prints an object. Whether the object is recursed depends on a variety of
  virtual function void print_object (string name, xil_object value,byte scope_separator=".");
    xil_component comp, child_comp;
    print_object_header(name,value,scope_separator);
    if(value != null)  begin
      if(!value.cycle_check.exists(value)) begin
        value.cycle_check[value] = 1;
        if(name=="" && value!=null) 
          m_scope.down(value.get_name());
        else
          m_scope.down(name);
        //Handle children of the comp
        if($cast(comp, value)) begin
          string name;
          if (comp.get_first_child(name))
            do begin
              child_comp = comp.get_child(name);
              if(child_comp.print_enabled)
                this.print_object("",child_comp);
            end while (comp.get_next_child(name));
        end
        // print members of object
        void'(value.sprint(this));
        if(name != "" && name[0] == "[")
          m_scope.up("[");
        else
          m_scope.up(".");
        value.cycle_check.delete(value);
      end
    end
  endfunction

  // print_object_header
  virtual function void print_object_header (string name,xil_object value, byte scope_separator=".");
    xil_printer_row_info row_info;
    xil_component comp;
    if(name == "") begin
      if(value!=null) begin
        if((m_scope.depth()==0) && $cast(comp, value)) begin
          name = comp.get_full_name();
        end
        else begin
          name=value.get_name();
        end
      end
    end
    if(name == "")
      name = "<unnamed>";
    m_scope.set_arg(name);
    row_info.level = m_scope.depth();
    row_info.name = adjust_name(m_scope.get(),scope_separator);
    row_info.type_name = (value != null) ?  value.get_type_name() : "object";
    row_info.size = "-";
    row_info.val = xil_object_value_str(value);
    m_rows.push_back(row_info);
  endfunction

  // Function: print_string
  // Prints a string field.
  virtual function void print_string (string name,string value,byte scope_separator=".");
    xil_printer_row_info row_info;
    if(name != "")
      m_scope.set_arg(name);
    row_info.level = m_scope.depth();
    row_info.name = adjust_name(m_scope.get(),scope_separator);
    row_info.type_name = "string";
    row_info.size = $sformatf("%0d",value.len());
    row_info.val = (value == "" ? "\"\"" : value);
    m_rows.push_back(row_info);
  endfunction

  // Function: emit
  // Emits a string representing the contents of an object
  // in a format defined by an extension of this object.
  virtual function string emit (); 
    `xil_error("NO_OVERRIDE","emit() method not overridden in printer subtype")
    return "";
  endfunction

  // Function: adjust_name
  // Prints a field's name, or ~id~, which is the full instance name.
  // The intent of the separator is to mark where the leaf name starts if the
  // printer if configured to print only the leaf name of the identifier. 
  virtual function string adjust_name(string id, byte scope_separator=".");
    return xil_leaf_scope(id, scope_separator);
  endfunction : adjust_name

  // Function: print_array_header
  // Prints the header of an array. This function is called before each
  // individual element is printed. <print_array_footer> is called to mark the
  // completion of array printing.
  virtual function void print_array_header (string name,int size,string arraytype="array",byte scope_separator=".");
    xil_printer_row_info row_info;
    if(name != "")
      m_scope.set_arg(name);
    row_info.level = m_scope.depth();
    row_info.name = adjust_name(m_scope.get(),scope_separator);
    row_info.type_name = arraytype;
    row_info.size = $sformatf("%0d",size);
    row_info.val = "-";
    m_rows.push_back(row_info);
    m_scope.down(name);
    m_array_stack.push_back(1);
  endfunction  : print_array_header

  // Function: print_array_footer
  // Prints the header of a footer. This function marks the end of an array
  // print. Generally, there is no output associated with the array footer, but
  // this method let's the printer know that the array printing is complete.
  virtual function void  print_array_footer (int size=0);
    if(m_array_stack.size()) begin
      m_scope.up();
      void'(m_array_stack.pop_front());
    end
  endfunction : print_array_footer

  // Utility methods
  virtual function bit istop ();
    return (m_scope.depth() == 0);
  endfunction : istop

  // Function- xil_object_value_str 
  function string xil_object_value_str(xil_object v);
    if (v == null)
      return "<null>";
    xil_object_value_str.itoa(v.get_inst_id());
    xil_object_value_str = {"@",xil_object_value_str};
  endfunction : xil_object_value_str

  // Function- xil_leaf_scope
  function string xil_leaf_scope (string full_name, byte scope_separator = ".");
    byte                      bracket_match;
    int                       pos;
    int                       bmatches;
    bmatches = 0;
    case(scope_separator)
      "[": bracket_match = "]";
      "(": bracket_match = ")";
      "<": bracket_match = ">";
      "{": bracket_match = "}";
      default: bracket_match = "";
    endcase

    //Only use bracket matching if the input string has the end match
    if(bracket_match != "" && bracket_match != full_name[full_name.len()-1])
      bracket_match = "";
    for(pos=full_name.len()-1; pos>0; --pos) begin
      if(full_name[pos] == bracket_match) bmatches++;
      else if(full_name[pos] == scope_separator) begin
        bmatches--;
        if(!bmatches || (bracket_match == "")) break;
      end
    end
    if(pos) begin
      if(scope_separator != ".") pos--;
      xil_leaf_scope = full_name.substr(pos+1,full_name.len()-1);
    end
    else begin
      xil_leaf_scope = full_name;
    end
  endfunction : xil_leaf_scope

endclass  :xil_printer

// Class: xil_table_printer
class xil_table_printer extends xil_printer;
  // Variables- m_max_*
  // holds max size of each column, so table columns can be resized dynamically
  protected int             m_max_name;
  protected int             m_max_type;
  protected int             m_max_size;
  protected int             m_max_value;

  // new
  function new(); 
    super.new();
  endfunction

  // calculate_max_widths
  function void calculate_max_widths();
     m_max_name=4;
     m_max_type=4;
     m_max_size = 4;
     m_max_value= 5;
     foreach(m_rows[j]) begin
        int name_len;
        xil_printer_row_info row = m_rows[j];
        name_len = indent*row.level + row.name.len();
        if (name_len > m_max_name)
          m_max_name = name_len;
        if (row.type_name.len() > m_max_type)
          m_max_type = row.type_name.len();
        if (row.size.len() > m_max_size)
          m_max_size = row.size.len();
        if (row.val.len() > m_max_value)
          m_max_value = row.val.len();
     end
  endfunction

  // emit
  function string emit();
    string s;
    string user_format;
    static string dash; 
    static string space; 
    string dashes;
    string linefeed = {"\n", ""};
    calculate_max_widths(); 
    begin
        int q[5];
        int m;
        int qq[$];
        q = '{m_max_name,m_max_type,m_max_size,m_max_value,100};
        qq.push_back(m_max_name);
        m = qq[0];
      if(dash.len()<m) begin
        dash = {m{"-"}};
        space = {m{" "}};
      end
    end
    if (header) begin
      string header;
      string dash_id, dash_typ, dash_sz;
      string head_id, head_typ, head_sz;
      dashes = {dash.substr(1,m_max_name+2)};
      header = {"Name",space.substr(1,m_max_name-2)};
      if (type_name) begin
        dashes = {dashes, dash.substr(1,m_max_type+2)};
        header = {header, "Type",space.substr(1,m_max_type-2)};
      end
      if (size) begin
        dashes = {dashes, dash.substr(1,m_max_size+2)};
        header = {header, "Size",space.substr(1,m_max_size-2)};
      end
      dashes = {dashes, dash.substr(1,m_max_value), linefeed};
      header = {header, "Value", space.substr(1,m_max_value-5), linefeed};
      s = {s, dashes, header, dashes};
    end
    foreach (m_rows[i]) begin
      xil_printer_row_info row = m_rows[i];
      string row_str;
      row_str = {space.substr(1,row.level * indent), row.name,
                 space.substr(1,m_max_name-row.name.len()-(row.level*indent)+2)};
      if (type_name)
        row_str = {row_str, row.type_name, space.substr(1,m_max_type-row.type_name.len()+2)};
      if (size)
        row_str = {row_str, row.size, space.substr(1,m_max_size-row.size.len()+2)};
      s = {s, row_str, row.val, space.substr(1,m_max_value-row.val.len()), linefeed};
    end
    s = {s, dashes};
    emit = {"", s};
    m_rows.delete();
  endfunction
endclass : xil_table_printer

class xil_reporter extends xil_object;
  function new (input string name = "");
    this.name = name;
  endfunction

  virtual function string get_type_name();
    return this.name;
  endfunction : get_type_name

endclass : xil_reporter

class xil_component extends xil_reporter;

  protected xil_component    m_children[string];
  protected xil_component    m_children_by_handle[xil_component];
  string                     type_name;
  bit                        print_enabled =1;

  function new(input string name="unnamed_component");
    super.new(name);
    this.type_name = name;
  endfunction : new
  
  // get_first_child
  function int get_first_child( string name);
    return m_children.first(name);
  endfunction

  // get_next_child
  function int get_next_child( string name);
    return m_children.next(name);
  endfunction

  // get_child
  function xil_component get_child(string name);
    if (m_children.exists(name))
      return m_children[name];
    `xil_warning("NOCHILD",{"Component with name '",name,
         "' is not a child of component '",get_full_name(),"'"})
    return null;
  endfunction

  virtual function string get_type_name();
    return this.type_name;
  endfunction 

endclass : xil_component

class xil_env extends xil_component;
  
  function new(input string name="unnamed_component");
    super.new(name);
  endfunction : new
endclass : xil_env

class xil_agent extends xil_component;
  
  function new(input string name="unnamed_component");
    super.new(name);
  endfunction : new
endclass : xil_agent

class xil_sequence_item extends xil_object;
  function new(input string name="unnamed_xil_sequence_item");
    super.new(name);
  endfunction : new

  function void set_id_info(xil_object p);
  endfunction : set_id_info

  virtual function string get_type_name();
    return "xil_sequence_item";
  endfunction : get_type_name

  virtual function string convert2string();
    return("");
  endfunction : convert2string

endclass: xil_sequence_item

class xil_analysis_port #(type T = xil_sequence_item) extends xil_component;
  logic                     enabled = 0;
  integer unsigned          item_cnt =0;
  T                         q[$];
  event                     item_cnt_event ; 

  function new(input string name="unnamed_component");
    super.new(name);
  endfunction : new

  function void set_enabled();
    `xil_info(this.get_name(), "Enabled xil_analysis_port for listening", XIL_VERBOSITY_NONE)
    this.enabled = 1;
  endfunction : set_enabled

  function void clr_enabled();
    `xil_info(this.get_name(), "Disabled xil_analysis_port for listening", XIL_VERBOSITY_NONE)
    this.enabled = 0;
  endfunction : clr_enabled

  function logic get_enabled();
    return(this.enabled);
  endfunction : get_enabled

  function integer unsigned get_item_cnt();
    return(this.item_cnt);
  endfunction : get_item_cnt

  virtual task write(input T trans);
    if (this.enabled) begin
      q.push_back(trans);
      this.item_cnt++;
      ->item_cnt_event ;
    end
  endtask: write

  virtual task get(output T trans);
    if (this.enabled == 1) begin
      while (item_cnt ==0) begin
        @(item_cnt_event);
      end  
      this.item_cnt--;
      ->item_cnt_event ;
      trans = q.pop_front();
    end else begin
      `xil_fatal(this.get_name(), "Attempted to GET from disabled analysis_port")
    end
  endtask : get

endclass : xil_analysis_port

class xil_sqr_if_base #(type T1=xil_object, T2=T1);
  integer unsigned          item_cnt = 0;
  integer unsigned          item_inflight_cnt = 0;
  integer unsigned          item_done_cnt = 0;
  integer unsigned          rsp_cnt = 0;
  integer unsigned          rsp_inflight_cnt = 0;
  integer unsigned          rsp_done_cnt = 0;
  T1                        item_q[$];
  T2                        rsp_q[$];
  event                     item_cnt_event ; 
  event                     rsp_cnt_event ; 
  event                     done_item_cnt_event ;
  event                     done_rsp_cnt_event ;

  virtual task get_next_item(output T1 t);
    while (item_cnt == 0) begin
      @(item_cnt_event);
    end
    this.item_cnt--;
  ->item_cnt_event ;
    t = this.item_q.pop_front();
    this.item_inflight_cnt++;
  endtask

  virtual function void try_next_item(output T1 t);
    if (item_cnt == 0) begin
      t = null;
    end else begin
      this.item_cnt--;
      ->item_cnt_event ;
      t = this.item_q.pop_front();
      this.item_inflight_cnt++;
    end
  endfunction : try_next_item

  virtual task wait_for_item_done(int transaction_id = -1);
    while (this.item_done_cnt == 0) begin
      @(done_item_cnt_event);
    end
    this.item_done_cnt--;
    ->done_item_cnt_event;
  endtask : wait_for_item_done

  virtual function void item_done(input T1 t = null);
    if (this.item_inflight_cnt == 0) begin
      `xil_fatal("xil_sqr_if_base", "ERROR: Attempted to double pop the item_done queue")
    end else begin
      this.item_done_cnt++;
      ->done_item_cnt_event ;
      this.item_inflight_cnt--;
    end
  endfunction

  virtual function void put_item(input T1 t = null);
    if (this.item_cnt > 5) begin
      `xil_fatal("xil_sqr_if_base", "ERROR: The sequence FIFO has overfilled. The item was not accepted.")
    end else begin
      this.item_q.push_back(t);
      this.item_cnt++;
      ->item_cnt_event ;
    end
  endfunction

  virtual task get_next_rsp(output T2 t);
    while (rsp_cnt == 0) begin
      @(rsp_cnt_event);
    end
    this.rsp_cnt--;
    ->rsp_cnt_event ;
    t = this.rsp_q.pop_front();
    this.rsp_inflight_cnt++;
  endtask

  virtual function void try_next_rsp(output T2 t);
    if (rsp_cnt == 0) begin
      t = null;
    end else begin
      this.rsp_cnt--;
      ->rsp_cnt_event ;
      t = this.rsp_q.pop_front();
      this.rsp_inflight_cnt++;
    end
  endfunction : try_next_rsp

  virtual task wait_for_rsp_done(int transaction_id = -1);
    while (this.rsp_done_cnt == 0) begin
      @(done_rsp_cnt_event);
    end
    this.rsp_done_cnt--;
    ->done_rsp_cnt_event;
  endtask : wait_for_rsp_done

  virtual function void rsp_done(input T2 t = null);
    if (this.rsp_inflight_cnt == 0) begin
      `xil_fatal("xil_sqr_if_base", "ERROR: Attempted to double pop the rsp_done queue")
    end else begin
      this.rsp_done_cnt++;
      ->done_rsp_cnt_event ;
      this.rsp_inflight_cnt--;
    end
  endfunction

  virtual function void put_rsp(input T2 t = null);
    if (this.rsp_cnt > 5) begin
      `xil_fatal("xil_sqr_if_base", "ERROR: The sequence FIFO has overfilled. The R was not accepted.")
    end else begin
      this.rsp_q.push_back(t);
      this.rsp_cnt++;
      ->rsp_cnt_event ;
    end
  endfunction

endclass : xil_sqr_if_base

class xil_seq_item_pull_port#(type REQ = xil_sequence_item, type RSP = REQ) extends xil_sqr_if_base#(REQ, RSP);
  string                    name;

  function new(input string name="unnamed_component");
    this.name = name;
  endfunction : new

endclass :xil_seq_item_pull_port


class xil_driver #(type REQ = xil_sequence_item, type RSP = REQ) extends xil_component;

  xil_seq_item_pull_port #(REQ, RSP) seq_item_port;

  // Port: rsp_port
  //
  // This port provides an alternate way of sending responses back to the
  // originating sequencer. Which port to use depends on which export the
  // sequencer provides for connection.

  xil_analysis_port #(RSP)          rsp_port;

  // Function: new
  //
  // Creates and initializes an instance of this class using the normal
  // constructor arguments for <xil_component>: ~name~ is the name of the
  // instance, and ~parent~ is the handle to the hierarchical parent, if any.

  function new (string name);
    super.new(name);
    seq_item_port    = new("seq_item_port");
    rsp_port         = new("rsp_port");
    this.rsp_port.set_enabled();
  endfunction : new

  const static string type_name = "xil_driver #(REQ,RSP)";

  virtual function string get_type_name ();
    return type_name;
  endfunction
endclass :xil_driver

class xil_monitor extends xil_component;

  function new(input string name="unnamed_component");
    super.new(name);
  endfunction : new

endclass : xil_monitor

endpackage : xil_common_vip_v1_0_0_pkg


