include <common.scad>
use <base.scad>
use <body.scad>
use <head.scad>

// Bring everything together to build a printable design.

for (a = [true, false]) {
  translate([0, a ? 0 : 20, 0]) {
    basic_body(zombie_arms=a);
    translate([30, 0, 0]) {
      arm();
      translate([20, 0, 0]) {
        arm();
      }
    }
  }
}

translate([0, -25, 0]) {
  zombie_head();
  translate([30, 0, 0]) {
    steve_head();
  }
}

translate([-50, 0, 0]) {
  base_chip();
  translate([0, 50, 0]) {
    base_chip();
  }
}

translate([-90, 0, 0]) {
  head_chip();
  translate([0, 30, 0]) {
    head_chip();
  }
}

translate([0, 60, 0]) {
  base();
  translate([50, 0, 0]) {
    base();
  }
}