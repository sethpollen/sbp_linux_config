$fa = 5;
$fs = 0.2;

// Standard print layer.
$zstep = 0.2;

eps = 0.0001;

// Clearance for a loose fitting joint (like a slide). Note that
// you typically have to take this much off both sides.
loose_clearance = 0.2;

// Radius 1mm. Centered. Extends along the Y axis.
module round_rail(length) {
  rotate([90, 0, 0])
    translate([0, 0, -length/2])
      cylinder(length, 1);
}

// Major radius 1mm. Centered. Extends along the Y axis.
module square_rail(length, major_radius=1) {
  rotate([90, 45, 0])
    cube([major_radius*sqrt(2), major_radius*sqrt(2), length], center=true);
}

// Major radius 1mm.
module octahedron() {
  // Top and bottom halves.
  for (a = [-1, 1])
    scale([1, 1, a])
      // Extrude a square into a pyramid.
      linear_extrude(1, scale=0)
        rotate([0, 0, 45])
          square(sqrt(2), center=true);
}

// 1mm chamfer.
module chamfered_cube(dims) {
  assert(dims.x >= 2);
  assert(dims.y >= 2);
  assert(dims.z >= 2);

  hull()
    for (a = [0, 1], b = [0, 1], c = [0, 1])
        translate([
          (dims.x - 2) * a + 1,
          (dims.y - 2) * b + 1,
          (dims.z - 2) * c + 1
        ])
          octahedron();
}