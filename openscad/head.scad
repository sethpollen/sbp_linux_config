// A small amount to make sure shapes overlap when needed. This
// is well below the resolution of my 3D printer, so it
// shouldn't affect the final result.
eps = 0.001;

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
          linear_extrude(chamfer, scale=0)
            rotate([0, 0, 45])
              square(norm([chamfer, chamfer]), center=true);
    }
  }
}

// Studs are 1.7mm high and 3mm in diameter. They are spaced
// 2mm in from the edges of an 18x18mm square.
module four_studs() {
  column_height = 1.2;
  radius = 1.5;
  displacement = 5.5;
  
  for (a = [-1, 1], b = [-1, 1]) {
    scale([a, b, 1]) {
      translate([displacement, displacement, 0]) {
        cylinder(column_height, radius, radius);
        translate([0, 0, column_height]) {
          scale = (radius-0.6)/radius;
          linear_extrude(0.5, scale=scale)
            circle(radius);
        }
      }
    }
  }
}

// Holes are designed to loosely fit over the studs.
module four_holes() {
  minkowski() {
    four_studs();
    sphere(0.5);
  }
}

// A stackable box, 18x18mm, with optional studs and holes.
module stackable_box(height, studs=true, holes=true) {
  difference() {
    union() {
      chamfered_box([18, 18, height]);
      if (studs)
        translate([0, 0, height - eps])
          four_studs();
    }
    if (holes)
      translate([0, 0, -eps])
        four_holes();
  }
}

// A stackable chip, for going on top of a head.
module chip() {
  stackable_box(3.5);
}

// A head, which is intended to have 2 chips stacked on top.
module head(face_raster) {
  difference() {
    // A 10mm head plus two 3.5mm chips comes to 17mm,
    // which is slightly less than the 18mm width. That's
    // by design. It looks better not to have such tall heads,
    // perhaps because the studs on top give the illusion
    // of added height.
    stackable_box(10, holes=false);
    
    // Bring the mask out a bit extra (0.05mm) to avoid
    // having it intersect the studs at all.
    translate([0, -9.05, 0])
      face(face_raster);
  }
}

// 'raster' is an array of 5 rows, where each row has 8
// elements. Each element should be in [0, 1]. A '1' means the
// given position will be fully engraved on the face.
// Returns a mask which should be subtracted from the head.
// The Z axis will coincide with the centerline of the 
// mask's front.
module face(raster) {
  // Below we use a unit of 1 to represent one pixel on
  // the face. Scale up to an 18mm face, 8 pixels wide.
  scale([2.25, 2.25, 2.25]) {
    translate([-4, -eps, -eps]) {
      difference() {
        // Begin with a filled-in face plate.
        translate([-eps, -eps, -eps])
          cube([8+2*eps, 0.9+2*eps, 5+2*eps]);
        
        // Subtract the material which needs to remain on the
        // head. Leave some support under each shelf.
        for (r = [0:4])
          for (c = [0:7])
            translate([c-eps, raster[r][c]-eps, 4-r-eps])
              rotate([90, 0, 90])
                translate([0, 0, -2*eps])
                  linear_extrude(1+4*eps)
                    polygon([
                      [   -2*eps,     -2*eps],
                      [0.9+2*eps, -0.5-2*eps],
                      [0.9+2*eps,    1+2*eps],
                      [   -2*eps,    1+2*eps],
                    ]);
      }
    }
  }
}

module creeper_head() {
  difference() {
    head([
      [0, 1, 1, 0, 0, 1, 1, 0],
      [0, 1, 1, 0, 0, 1, 1, 0],
      [0, 0, 0, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 0, 0, 1, 0, 0],
    ]);
  }
}

module zombie_head() {
  difference() {
    head([
      [0, 0, 0,   0,   0,   0,   0, 0],
      [0, 1, 1,   0,   0,   1,   1, 0],
      [0, 0, 0,   0.7, 0.7, 0,   0, 0],
      [0, 0, 0.2, 0,   0,   0.2, 0, 0],
      [0, 0, 0.2, 0,   0,   0.2, 0, 0],
    ]);
  }
}

module skeleton_head() {
  difference() {
    head([
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 1, 1, 0, 0, 1, 1, 0],
      [0, 0, 0, 1, 1, 0, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
    ]);
  }
}

module spider_head() {
  difference() {
    head([
      [1, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 0, 1],
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 1, 0, 0, 1, 0, 0],
    ]);
  }
}
