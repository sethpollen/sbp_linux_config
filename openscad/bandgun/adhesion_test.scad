include <common.scad>

translate([-1, 0, 0])
  chamfered_cube([70, 7, 3]);

translate([0, -4, 0]) {
  linear_extrude(0.2) {
    translate([0, 0.4, 0]) square([8, 4]);
    translate([10, 0.5, 0]) square([8, 4]);
    translate([20, 0.6, 0]) square([8, 4]);
    translate([30, 0.7, 0]) square([8, 4]); // This one is nice.
    translate([40, 0.8, 0]) square([8, 4]);
    translate([50, 0.9, 0]) square([8, 4]);
    translate([60, 1.0, 0]) square([8, 4]);
  }
}

// TODO: the test indicates that 0.3 is a good offset from under a bevel.