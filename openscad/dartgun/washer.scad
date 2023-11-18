// Retention washer for 1/8" steel pins.

include <common.scad>

pin_diameter = 3.175;
pin_cavity_diameter = pin_diameter + 0.1;
washer_body_diameter = pin_diameter + 4;
hole_depth = 3.5;
ceiling_thickness = 1.6;
flange_thickness = 2.2;
flange_length = 3.5;
flange_width = washer_body_diameter - 2;

module washer() {
  $fn = 50;
  
  difference() {
    union() {
      cylinder(flange_thickness, d=washer_body_diameter);
      
      intersection() {
        translate([0, 0, flange_thickness])
          scale([1, 1, (hole_depth + ceiling_thickness - flange_thickness)*2/washer_body_diameter])
            sphere(washer_body_diameter/2);
        translate([0, 0, 10])
          cube(20, center=true);
      }
      
      intersection() {
        cylinder(flange_thickness, d=washer_body_diameter+2*flange_length);
        cube([flange_width, 20, 20], center=true);
      }
    }
    
    translate([0, 0, -eps]) {
      cylinder(hole_depth, d=pin_cavity_diameter);
      cylinder(0.3, d=pin_cavity_diameter+0.6);
    }
  }
}

module washer_claw() {
  $fn = 50;
  ceiling = 1.4;
  wall = 2;

  difference() {
    intersection() {
      translate([-flange_width/2, washer_body_diameter/2, -1])
        chamfered_cube([flange_width+wall, flange_length+wall, 1+flange_thickness+0.2+ceiling], 0.6);
      translate([0, 0, 10])
        cube(20, center=true);
    }
    intersection() {
      translate([0, 0, -eps])
        cylinder(flange_thickness+0.2, d=washer_body_diameter+2*flange_length+0.2);
      cube([flange_width+2*eps, 20, 20], center=true);
    }
  }
}

washer();
