// Unless otherwise specified, each resulting shape is
// resting on the XY plane, centered on the Z axis.

// A small amount to make sure shapes overlap when needed. This
// is well below the resolution of my 3D printer, so it
// shouldn't affect the final result.
eps = 0.001;

// These are reasonable settings for interactive renderings and
// for 3D printing.
$fa = 10;
$fs = 0.4;

// Standard chamfer on all edges and corners. This makes the
// pieces more comfortable to handle.
chamfer = 0.5;

// A regular octahedron centered on the origin with its vertices
// on the axes. 'axis' gives its full length along each axis.
module octahedron(axis) {
  // Top and bottom halves.
  for (a = [-1, 1])
    scale([1, 1, a])
      // Extrude a square into a pyramid.
      linear_extrude(axis/2, scale=0)
        rotate([0, 0, 45])
          square(norm([axis/2, axis/2]), center=true);
}

// 'd' is the outer dimensions of the box.
module chamfered_box(d) {
  assert(d.x >= 1);
  assert(d.y >= 1);
  assert(d.z >= 1);

  // Raise the result up so it is resting on the XY plane.
  translate([0, 0, d.z/2]) {
    minkowski() {
      // The desired cube, scaled back by the chamfer distance
      // in all directions.
      cube(d - [chamfer*2, chamfer*2, chamfer*2], center=true);
      octahedron(chamfer*2);
    }
  }
}

module chamfered_disk(height, radius) {
  assert(radius >= 0.5);
  assert(height >= 1);

  // Raise the result up so it is resting on the XY plane.
  translate([0, 0, height/2]) {
    minkowski() {
      // The desired disk, scaled back by the chamfer distance
      // in all directions.
      cylinder(height-chamfer*2, r=radius-chamfer, center=true);
      octahedron(chamfer*2);
    }
  }
}
