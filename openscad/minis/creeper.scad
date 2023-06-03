use <base.scad>
include <body.scad>
use <common.scad>
use <head.scad>

module creeper_body() {
  difference() {
    union() {
      chamfered_box([torso_breadth, torso_thickness, 24]);
      chamfered_box([8, 8, 29]);
      for (a = [-1, 1], b = [-1, 1])
        scale([a, b, 1])
          translate([torso_breadth/4, 5.5, 17])
            chamfered_box([torso_breadth/2, 7, 12]);
    }
    
    // Head locking socket.
    locking_socket_bottom();

    // Baseplate locking socket.
    translate([0, 0, 29])
      locking_socket_top();
  }
}

module creeper_preview() {
  color(c = [0.5, 0.9, 0.3]) {
    translate([0, 0, 0]) base();
    translate([0, 0, 32.5])
      rotate([0, 180, 0]) creeper_body();
    translate([0, 0, 32.5]) creeper_head();
    translate([0, 0, 42.5]) light_weapon();
    translate([0, 0, 46]) light_armor();
  }
}

// Printable.
creeper_body();
translate([0, -25, 0]) creeper_head();
translate([0, 40, 0]) base();