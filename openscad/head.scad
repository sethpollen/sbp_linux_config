// A small amount to make sure shapes overlap when needed. This
// is well below the resolution of my 3D printer, so it
// shouldn't affect the final result.
epsilon = 0.001;

// Unless otherwise specified, each resulting shape is
// Resting on the XY plane, centered on the Z axis.

// 'd' is the outer dimensions of the box. A chamfer of 0.5mm
// will be applied to all edges and corners.
module chamfered_box(d) {
  chamfer = 0.5;
  assert(d.x >= 1);
  assert(d.y >= 1);
  assert(d.z >= 1);

  // Raise the result up so it is resting on the XY plane.
  translate([0, 0, d.z/2]) {
    minkowski() {
      // The desired cube, scaled back by the chamfer distance
      // in all directions.
      cube(d - [chamfer*2, chamfer*2, chamfer*2], center=true);
      
      // A regular octahedron measuring twice the chamfer
      // distance along its axis.
      for (a = [-1, 1])
        scale([1, 1, a])
          linear_extrude(chamfer, scale = 0)
            rotate([0, 0, 45])
              square(norm([chamfer, chamfer]), center = true);
    }
  }
}

// Studs are 1.7mm high and 3mm in diameter. They are spaced
// 2mm in from the edges of an 18x18mm square.
module four_studs() {
  dome_height = 0.5;
  column_height = 1.2;
  radius = 1.5;
  displacement = 5.5;
  
  for (a = [-1, 1], b = [-1, 1]) {
    scale([a, b, 1]) {
      translate([displacement, displacement, 0]) {
        cylinder(column_height, radius, radius);
        translate([0, 0, column_height])
          scale([radius, radius, dome_height])
            sphere(1);
      }
    }
  }
}

// Holes are designed to loosely fit over the studs.
module four_holes() {
  dome_height = 0.5;
  column_height = 1.8;
  radius = 2;
  displacement = 5.5;
  
  for (a = [-1, 1], b = [-1, 1]) {
    scale([a, b, 1]) {
      translate([displacement, displacement, 0]) {
        cylinder(column_height, radius, radius);
        translate([0, 0, column_height]) {
          scale = (radius - dome_height) / radius;
          linear_extrude(dome_height, scale = scale)
            circle(radius);
        }
      }
    }
  }
}

// A stackable box, 18x18mm, with optional studs and holes.
module stackable_box(height, studs=true, holes=true) {
  difference() {
    union() {
      chamfered_box([18, 18, height]);
      if (studs)
        translate([0, 0, height - epsilon])
          four_studs();
    }
    if (holes)
      translate([0, 0, -epsilon])
        four_holes();
  }
}

// A stackable chip, for going on top of a head.
module chip() {
  stackable_box(3.5);
}

// A blank head, which is intended to have 2 chips stacked on
// top.
module head() {
  stackable_box(11, holes=false);
}

chip();

$fa = 10;
$fs = 0.2;
