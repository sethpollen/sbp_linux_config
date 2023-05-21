// A box with a 0.5mm chamfer on all edges and corners.
module chamfered_box(d) {
  difference() {
    cube(d, center=true);
    
    // Edge chamfers.
    for (a = [1, -1], b = [1, -1]) {
      // Chamfers parallel to X axis.
      scale([1, a, b]) {
        translate([0, (d.y-0.5)/2, (d.z-0.5)/2]) {
          rotate([-45, 0, 0]) {
            translate([0, 0, 0.5]) {
              cube([d.x+1, 1, 1], center=true);
            }
          }
        }
      }
    
      // Chamfers parallel to Y axis.
      scale([a, 1, b]) {
        translate([(d.x-0.5)/2, 0, (d.z-0.5)/2]) {
          rotate([0, -45, 0]) {
            translate([0.5, 0, 0]) {
              cube([1, d.y+1, 1], center=true);
            }
          }
        }
      }
      
      // Chamfers parallel to Z axis.
      scale([a, b, 1]) {
        translate([(d.x-0.5)/2, (d.y-0.5)/2, 0]) {
          rotate([0, 0, -45]) {
            translate([0, 0.5, 0]) {
              cube([1, 1, d.z+1], center=true);
            }
          }
        }
      }
    }
    
    // TODO: add corner chamfers
  }
}

chamfered_box([10, 15, 20]);