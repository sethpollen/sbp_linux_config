linear_extrude(2) {
  difference() {
    union() {
      for (a = [0:0.125:1]) {
        rotate([0, 0, a*360]) {
          translate([0, 25])
            square([9, 50], center=true);
          translate([0, 50])
            for (b = 25 * [1, -1])
              rotate([0, 0, b])
                translate([0, 18])
                  square([8, 40], center=true);
        }
      }
      circle(15);
    }
    
    polygon([
      [6, 0],
      [-3, -3],
      [-3, 3],
    ]);
  }
}