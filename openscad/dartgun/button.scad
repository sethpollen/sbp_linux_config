// Retention washer for 1/8" steel pins.

include <common.scad>
include <spiral.scad>

pin_diameter = 3.175;
grip = 1.2;

flap_thickness = 1.1;
flap_turns = 1.2;
flap_slope = 3.7;
flap_start_radius = pin_diameter/2 + flap_thickness/2 - grip/2;

flap_height = 4;
z_gap = 0.6;

module flaps_2d() {
  for (a = [0, 180])
    rotate([0, 0, a])
      spiral(flap_start_radius, flap_slope, flap_turns, flap_thickness);
  
  difference() {
    // A ring to hold the pin all the way around.
    circle(d=pin_diameter - grip + 2*flap_thickness);
    circle(d=pin_diameter - grip);
  
    // Split the ring into separate halves.
    rotate([0, 0, -40])
      square([10, 0.6], center=true);
  }
}

for (z = [0:0.2:0.8])
  translate([0, 0, z])
    linear_extrude(0.2)
      offset(-0.22*(1-z))
        flaps_2d();

translate([0, 0, 1])
  linear_extrude(flap_height-1)
    flaps_2d();

linear_extrude(flap_height + z_gap) {
  difference() {
    circle(r=pin_diameter/2 + flap_turns*flap_slope + flap_thickness/2 + 0.5);
    circle(r=pin_diameter/2 + flap_turns*flap_slope - flap_thickness/2);
  }
}

translate([0, 0, flap_height + z_gap]) {
  hull() {
    linear_extrude(eps)
      circle(r=pin_diameter/2 + flap_turns*flap_slope + flap_thickness/2 + 0.5);
    
    translate([0, 0, 1])
      linear_extrude(eps)
        circle(r=pin_diameter/2 + flap_turns*flap_slope + flap_thickness/2 + 0.1);
  }
}