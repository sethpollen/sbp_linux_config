eps = 0.001;
$fn = 50;

// Table is 1.5" thick.
table_thickness = 1.5 * 25.4;

gauge = 7;
depth = 11;
flat = 40;

fillet = 17;
chamfer = gauge - 2;

module chop_2d() {
  difference() {
    square(1);
    circle(1);
  }
}

module piece_2d() {
  difference() {
    union() {
      // Finger.
      translate([0, table_thickness])
        square([depth, gauge]);

      // Vertical.
      translate([depth, 0])
        square([gauge + flat, table_thickness + gauge]);
    }
    
    translate([depth + gauge + fillet, fillet + gauge]) {
      scale(fillet) {
        circle(1);
        translate([-1-eps, 0])
          square(100);
        translate([0, -1-eps])
          square(100);
      }
    }
    
    translate([depth + gauge + flat + eps, gauge - chamfer])
      scale(chamfer)
        translate([-1, 0])
          chop_2d();
  
    translate([depth + eps + gauge - chamfer, table_thickness + gauge + eps])
      scale(chamfer)
        translate([0, -1])
          chop_2d();
  }  
}

piece_2d();