// Unless otherwise specified, each resulting shape is
// resting on the XY plane, centered on the Z axis.

// A small amount to make sure shapes overlap when needed. This
// is well below the resolution of my 3D printer, so it
// shouldn't affect the final result.
eps = 0.001;

// High quality for printing.
$fa = 5;
$fs = 0.4;

module repeatx(n, spacing) {
  for (i = [1:n])
    translate([(i-1)*spacing, 0, 0])
      children();
}

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

locking_lug_dims = [2.3, 2.3, 1.8+2*eps];

// A snug fit for gluing.
module locking_lug() {
  // Taper the lug slightly, to counteract the printing effect
  // which spreads the top layer slightly.
  linear_extrude(locking_lug_dims.z, scale=0.95)
    square([locking_lug_dims.x, locking_lug_dims.y],
            center=true);
}

// Make extra sure the lug will fit all the way into the hole.
locking_socket_extra_depth = 0.7;

module locking_socket_top() {
  translate([
    0, 0,
    -(locking_lug_dims.z+locking_socket_extra_depth)/2+eps
  ]) {
    cube(locking_lug_dims + [
      0.15, 0.15,
      locking_socket_extra_depth
    ], center=true);
  }
}

module locking_socket_bottom() {
  translate([
    0, 0,
    (locking_lug_dims.z+locking_socket_extra_depth)/2-eps
  ]) {
    cube(locking_lug_dims + [
      // When printing this on the bottom of a model, it
      // needs to be a bit wider to account for
      // elephant-foot.
      0.3, 0.3,
      locking_socket_extra_depth
    ], center=true);
  }
}

// A pin which can be used to join two locking sockets.
module locking_pin() {
  dims = [
    locking_lug_dims.x,
    // Lay the pin on its side for more reliable printing.
    locking_lug_dims.z*2 + locking_socket_extra_depth/2,
    locking_lug_dims.y,
  ];
  translate([0, 0, dims.z/2])
    cube(dims, center=true);
}
