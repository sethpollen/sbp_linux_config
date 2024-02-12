include <base.scad>

module support(y, z) {
  length = 10;
  
  translate([0, y, z])
    cube([length, 0.4, 0.6], center=true);
  
  for (a = [-1, 1]) {
    scale([a, 1, 1]) {
      hull() {
        translate([length/2, y, z])
          cube(0.6, center=true);
        translate([length/2, y-2, 0])
          cube([4, 4, 1]);
      }
    }
  }
}

module import_and_position() {
  inflate = 1.75;
  translate([0, 0.4, 0])
    scale(inflate * [1, 1, 1])
      translate([-125, 6, -96.805])
        rotate([90, 0, 0])
          import("fixed/alien.stl");
}

module alien(add_support=true) {
  difference() {
    import_and_position();

    // Chop off the end of the tail, to reduce overhang.
    translate([0, -0.5, 28.5])
      cube([100, 2, 2], center=true);
  }
  
  if (add_support) {
    support(0.4, 4.94);
    support(-8.9, 10.5);
  }
}

module alien_base() {
  // Remove the hole.
  hull()
    base();
  
  // Guides for where to glue it.
  translate([0, 0, 4]) {
    intersection() {
      cube([100, 100, 0.4], center=true);
      alien(add_support=false);
    }
  }
}

alien();