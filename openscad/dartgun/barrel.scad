include <common.scad>
include <rail.scad>

// Should be wide enough to accommodate whatever bore structure we
// want.
barrel_width = 20;
barrel_height = 34;

barrel_length = 244;
// See results from bore_test.scad.
main_bore = 13.8;

// TODO: merge with cam_cavity_diameter
barrel_gap = 7.4;

module barrel() {
  // Make the bore with high precision.
  $fa = 5;
  
  difference() {
    translate([0, barrel_height/2, 0])
      rail(barrel_width, barrel_length, barrel_height/2 - barrel_gap/2);
    
    translate([0, 0, -eps])
      cylinder(barrel_length+2*eps, d=main_bore);
  }
  
  // Brims to prevent warping.
  for (z = [-7 + 0.2, barrel_length - 0.2])
    translate([-barrel_width/2, -0.2 + barrel_height/2 + rail_notch_depth, z])
      cube([barrel_width, 0.2, 7]);
}

// The barrel needs a particular orientation on the build plate.
module barrel_print() {
  // This particular orientation ensures that the first bridging layer goes
  // the short way across the gaps, instead of the long way.
  rotate([-90, 0, -45])
    barrel();
}

// Volume to remove from a piece which is intended to mate with the barrel.
module barrel_cutout() {
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([-barrel_height/2, -barrel_length/2, 0])
        rotate([0, 90, 90])
          rail(barrel_width, barrel_length, barrel_height/2 - barrel_gap/2, cavity=true);
  
  // Only allow the piece to intrude 1mm into the barrel gap. This is enough to keep the
  // barrel pieces properly spaced.
  cube([barrel_gap + eps, barrel_length, barrel_width - 2], center=true);
}

barrel_cutout();