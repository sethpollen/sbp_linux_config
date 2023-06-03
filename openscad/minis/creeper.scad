use <base.scad>
include <body.scad>
use <common.scad>
use <head.scad>

module creeper_body() {
  difference() {
    union() {
      translate([0, 0, 5])
        chamfered_box([torso_breadth, torso_thickness, 22]);
      
      // Housing around baseplate socket.
      chamfered_box([7, 15, 11]);
      
      // Legs.
      for (a = [-1, 1], b = [-1, 1])
        scale([a, b, 1])
          translate([torso_breadth/4, 6.5, 0])
            chamfered_box([torso_breadth/2, 7, 12]);
      
      // Head locking lug.
      translate([0, 0, 27]) locking_lug();
      
      // Support bevel underneath body.
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([8.5, 0, 5])
            rotate([0, -15, 0])
              translate([-4, 0, 4])
                cube([8, 8, 8], center=true);
    }
    
    // Baseplate locking socket.
    locking_socket_bottom();
  }
}

module creeper_preview() {
  color(c = [0.5, 0.9, 0.3]) {
    translate([0, 0, 0]) base();
    translate([0, 0, 3.5]) creeper_body();
    translate([0, 0, 30.5]) creeper_head();
    translate([0, 0, 40.5]) light_weapon();
    translate([0, 0, 44]) light_armor();
  }
}

// Printable.
creeper_body();
translate([0, -25, 0]) creeper_head();
translate([0, 40, 0]) base();