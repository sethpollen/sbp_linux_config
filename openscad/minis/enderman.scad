use <base.scad>
include <body.scad>
use <head.scad>

// 0 for preview.
// 1 for printing.
mode = 1;

module enderman_arm() {
  arm(tall=true, bony = true);
}

module enderman_body() {
  basic_body(arms=[ARM_DOWN_FUSED,ARM_DOWN_FUSED], tall=true);
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([13, 0, 30-eps])
        rotate([0, 180, 0])
          enderman_arm();
}

module enderman_preview() {
  color(c = [0.4, 0.4, 0.4]) {
    translate([0, 0, 0]) base();
    translate([0, 0, 47.5]) rotate([0, 180, 0]) enderman_body();
    translate([0, 0, 47.5]) enderman_head();
    translate([0, 0, 57.5]) light_weapon();
    translate([0, 0, 61]) light_armor();
  }
}

if (mode == 0) {
  enderman_preview();
}

if (mode == 1) {
  enderman_body();
  translate([0, 35, 0]) base();
  translate([0, -30, 0]) enderman_head();
}