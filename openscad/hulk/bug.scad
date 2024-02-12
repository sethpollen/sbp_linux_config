include <base.scad>

module support(y, z) {
  length = 26.5;
  
  translate([0, y, z])
    cube([length, 0.4, 0.6], center=true);
  
  for (a = [-1, 1]) {
    scale([a, 1, 1]) {
      // Column.
      hull() {
        translate([length/2, y, z-1])
          cube(0.6, center=true);
        translate([length/2, y-2, 0])
          cube([4, 4, 1]);
      }
      
      // Fillet.
      hull() {
        translate([length*0.2, y - 0.3, z - 0.3])
          cube([length*0.3, 0.6, 0.6]);
        translate([length/2, y, z - 5.5])
          cube([eps, 1.5, eps], center=true);
      }
    }
  }
}

module alien() {
  // Base, with no hole.
  hull()
    base();
  
  inflate = 1.75;

  translate([0, 0, 4])
    scale(inflate * [1, 1, 1])
      translate([0, -9.5, -2.86])
        rotate([90, 0, 0])
          import("fixed/alien.stl");
  
  support(0, 9.13);
  support(-9.3, 14.7);
}

alien();