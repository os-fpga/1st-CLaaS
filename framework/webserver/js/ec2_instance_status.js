// <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
// This file creates a web component that represents the state of an AWS EC2 instance.

window.customElements.define('ec2-instance-status', class extends HTMLElement {
  static get observedAttributes() {
    return ['status', 'size'];
  }
  constructor() {
    super();
    var shadowRoot = this.attachShadow({mode: 'open'});
    shadowRoot.innerHTML = `
      <style>
        @import "https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css";
      </style>
      <span>
        <i class="fa fa-circle"></i>
      </span>
    `;
    this.span = $(shadowRoot).find("span");
    // Status => color map.
    this.status_map = {
      "running": {color: "#00CC00", icon: "circle"},
      "stopping": {color: "#CC0000", icon: "spinner"},
      "stopped": {color: "#CC0000", icon: "circle"},
      "pending": {color: "blue", icon: "spinner"},
      "unknown": {color: "gray", icon: "circle"}
    }
  }
  attributeChangedCallback(name, old_val, new_val) {
    switch (name) {
      case 'status':
        $(this.span).css("color", this.status_map[new_val].color);
        $("i", this.span).attr("class", `fa fa-${this.status_map[new_val].icon}`);
        break;
      case 'size':
        $(this.span).css("font-size", new_val);
        break;
    }
  }
  connectedCallback() {
    // Default attributes.
    if (!this.hasAttribute("status")) {this.setAttribute("status", "stopped")};
    if (!this.hasAttribute("size"  )) {this.setAttribute("size"  , "25px"   )};
  }

  set status(val) {
    this.setAttribute("status", val);
  }
  get status() {
    return this.getAttribute("status");
  }
  set size(val) {
    this.setAttribute("size", val);
  }
  get size() {
    return this.getAttribute("size");
  }
});
