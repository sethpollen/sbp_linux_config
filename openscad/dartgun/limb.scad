include <common.scad>

// Extra foot, since we will print with a brim.
brim_foot = 0.6;

module profile(height) {
  hull() {
    // Chamfered bottom.
    linear_extrude(eps)
      offset(delta=-brim_foot)
        children();
    
    // Main body.
    translate([0, 0, brim_foot])
      linear_extrude(eps)
        children();
    translate([0, 0, height])
      linear_extrude(eps)
        children();
  }
}

base_thickness = 3.5;
tip_thickness = 1.4;
base_length = 30;
total_length = 200;
width = 20;

profile(width)
  hull()
    for (a = [-1, 1])
      scale([a, 1, 1])
        polygon([
          [0, 0],
          [base_thickness/2, 0],
          [base_thickness/2, base_length],
          [tip_thickness/2, total_length],
        ]);