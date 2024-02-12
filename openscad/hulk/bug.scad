include <base.scad>

// Base, with no hole.
hull()
  base();

inflate = 1.75;

translate([0, 0, 4])
  scale(inflate * [1, 1, 1])
    translate([0, -9.5, -2.86])
      rotate([90, 0, 0])
        import("fixed/alien.stl");
