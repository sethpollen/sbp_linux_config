include <common.scad>

// Studs are 1.6mm high and 2.5mm across.
stud_width = 2.5;

// Studs are spaced 2mm in from the edges of an 18x18mm square.
stud_inset = 2;

module stud() {
  translate([0, 0, -eps])
    linear_extrude(1.1)
      square(stud_width, center=true);
  translate([0, 0, 1.1-2*eps])
    linear_extrude(0.5, scale = 0.6)
      square(stud_width, center=true);
}

module make_studs() {
  displacement = (18/2)-(stud_width/2)-stud_inset;  
  for (a = [-1, 1], b = [-1, 1])
    translate([a*displacement, b*displacement, 0])
      children();
}

// A stackable box, 18x18mm, with optional studs and holes.
module stackable_box(height, studs=true, holes=true) {
  if (studs)
    translate([0, 0, height - eps])
      make_studs() stud();

  difference() {
    chamfered_box([18, 18, height]);
    
    if (holes) {
      make_studs() {
        minkowski() {
          stud();
          sphere(r=0.5, $fn=10);
        }
      }
    }
  }
}

// A stackable chip, for going on top of a head.
module head_chip() {
  stackable_box(3.5);
}

// A head, which is intended to have 2 chips stacked on top.
module head(face_raster) {
  // Lift the head slightly to fit the lug underneath.
  translate([0, 0, locking_lug_dims.z]) {
    difference() {
      // A 10mm head plus two 3.5mm chips comes to 17mm,
      // which is slightly less than the 18mm width. That's
      // by design. It looks better not to have such tall 
      // heads, perhaps because the studs on top give the
      // illusion of added height.
      stackable_box(10, holes=false);
      
      // Bring the mask out a bit extra (0.05mm) to avoid
      // having it intersect the studs at all.
      translate([0, -9.05, 0])
        face(face_raster);
    }
    
    // A lug for gluing to a body.
    scale([1, 1, -1])
      locking_lug();
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
  head([
    [0, 1, 1, 0, 0, 1, 1, 0],
    [0, 1, 1, 0, 0, 1, 1, 0],
    [0, 0, 0, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0],
  ]);
}

module zombie_head() {
  head([
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0],
    [0.0, 0.0, 0.0, 0.8, 0.8, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.2, 0.2, 0.2, 0.2, 0.0, 0.0],
    [0.0, 0.0, 0.2, 0.2, 0.2, 0.2, 0.0, 0.0],
  ]);
}

module skeleton_head() {
  head([
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 0, 0, 1, 1, 0],
    [0, 0, 0, 1, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ]);
}

module spider_head() {
  head([
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 1, 1, 1, 0, 1],
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0],
  ]);
}

module steve_head() {
  head([
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0.7, 1, 0, 0, 1, 0.7, 0],
    [0, 0, 0, 0.8, 0.8, 0, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
  ]);
}

// Demo.
head_chip();
