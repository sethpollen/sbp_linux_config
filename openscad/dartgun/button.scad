// Retention washer for 1/8" steel pins.

include <common.scad>
include <spiral.scad>

pin_diameter = 3.175;
grip = 1;

finger_thickness = 1.1;
finger_turns = 1.2;
finger_slope = 3.7;
finger_start_radius = pin_diameter/2 + finger_thickness/2 - grip/2;

clearance = 0.6;

module flaps() {
  for (a = [0, 180])
    rotate([0, 0, a])
      spiral(finger_start_radius, finger_slope, finger_turns, finger_thickness);
}

for (z = [0:0.2:0.8])
  translate([0, 0, z])
    linear_extrude(0.2)
      offset(-0.22*(1-z))
        flaps();

translate([0, 0, 1])
  linear_extrude(3)
    flaps();

linear_extrude(4 + clearance) {
  difference() {
    circle(r=pin_diameter/2 + finger_turns*finger_slope + finger_thickness/2 + 0.5);
    circle(r=pin_diameter/2 + finger_turns*finger_slope - finger_thickness/2);
  }
}

translate([0, 0, 4 + clearance]) {
  hull() {
    linear_extrude(eps)
      circle(r=pin_diameter/2 + finger_turns*finger_slope + finger_thickness/2 + 0.5);
    
    translate([0, 0, 1])
      linear_extrude(eps)
        circle(r=pin_diameter/2 + finger_turns*finger_slope + finger_thickness/2 + 0.1);
  }
}