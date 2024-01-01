// TODO: remove this when done.

include <common.scad>

h = 9;

rotate([90, 0, 0]) {
  difference() {
    linear_extrude(6) {
      difference() {
        square([43, h]);
        translate([6, h/2])
          octagon(nail_loose_diameter);
        translate([14, h/2])
          octagon(nail_loose_diameter-0.1);
        translate([22, h/2])
          octagon(nail_loose_diameter-0.2);
        translate([30, h/2])
          octagon(nail_loose_diameter-0.3);
      }
    }
    
    translate([34, h/4, 4])
      linear_extrude(10)
        text("sm", h/2);
  }
}