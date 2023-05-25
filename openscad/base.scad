include <common.scad>

// A chamfer of 0.5mm will be applied to all edges.
module chamfered_disk(radius, height) {
  chamfer = 0.5;
  assert(radius >= 0.5);
  assert(height >= 1);

  // Raise the result up so it is resting on the XY plane.
  translate([0, 0, height/2]) {
    minkowski() {
      // The desired disk, scaled back by the chamfer distance
      // in all directions.
      cylinder(height-chamfer*2, r=radius-chamfer, center=true);
      
      // A regular octahedron measuring twice the chamfer
      // distance along its axis.
      //
      // TODO: dedupe
      for (a = [-1, 1])
        scale([1, 1, a])
          linear_extrude(chamfer, scale=0)
            rotate([0, 0, 45])
              square(norm([chamfer, chamfer]), center=true);
    }
  }
}

chamfered_disk(20, 3.5);