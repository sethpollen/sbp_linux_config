// Retention washer for 1/8" steel pins.

include <common.scad>

pin_diameter = 3.175;
washer_body_diameter = pin_diameter + 4;
hole_depth = 3;
floor_thickness = 1;
flange_thickness = 2;
flange_width = 3.5;

module washer() {
  $fn = 60;
  
  difference() {
    union() {
      cylinder(hole_depth, d=washer_body_diameter);
      translate([0, 0, hole_depth])
        cylinder(floor_thickness, d1=washer_body_diameter, d2=washer_body_diameter-2*floor_thickness);
      intersection() {
        cylinder(flange_thickness, d=washer_body_diameter+2*flange_width);
        cube([washer_body_diameter-2, 20, 20], center=true);
      }
    }
    translate([0, 0, -eps])
      cylinder(hole_depth, d=pin_diameter);
  }
}

washer();