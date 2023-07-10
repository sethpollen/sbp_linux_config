$fa = 5;
$fs = 0.2;

// Half of a standard print layer.
$zstep = 0.1;

eps = 0.0001;

// Clearance for a loose fitting joint (like a slide). Note that
// you typically have to take this much off both sides.
loose_clearance = 0.2;

// Radius 1. Centered. Extends along the Y axis.
module round_rail(length) {
  rotate([90, 0, 0])
    translate([0, 0, -length/2])
      cylinder(length, 1);
}

// Major radius 1. Centered. Extends along the Y axis.
module square_rail(length) {
  rotate([90, 45, 0])
    cube([sqrt(2), sqrt(2), length], center=true);
}
