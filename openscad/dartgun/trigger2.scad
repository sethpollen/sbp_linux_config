include <common.scad>
include <barrel2.scad>
include <link.scad>

receiver_length = 60;

module receiver() {
  intersection() {
    union() {
      translate([0, 0, 0])
        rotate([0, 90, 0])
          slider(receiver_length, slot=30);
      
      translate([slider_height/2, -receiver_length/2 + main_diameter/2, 0])
        rotate([0, -90, 0])
          link_anchor(enclosure_thickness=10, spread=2.1);
    }
    
    // Remove the top half.
    translate([0, 0, -slider_width/4])
      cube([100, receiver_length, slider_width/2], center=true);
  }
}

receiver();
