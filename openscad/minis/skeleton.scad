include <common.scad>
use <base.scad>
include <body.scad>
use <head.scad>

// 0 for preview.
// 1 for printing the main pieces.
// 2 for printing the bow arms, which are a bit more sensitive
//   to print.
mode = 1;

module skeleton_arm(with_bow=false) {
  arm(bony=true);
  if (with_bow) {
    bow();
  }
}

module skeleton_body() {
  basic_body(arms=[ARM_DOWN_FUSED,ARM_OUTSTRETCHED], bony=true);
  translate([-13, 0, 20-eps])
    rotate([0, 180, 0])
      skeleton_arm();
}

module skeleton_preview() {
  color(c = [0.8, 0.8, 0.8]) {
    translate([0, 0, 0]) base();
    translate([0, 0, 34.5]) rotate([0, 180, 0]) skeleton_body();
    translate([0, 0, 34.5]) skeleton_head();
    translate([-13, -16, 30.5]) rotate([-90, 0, 0])
      skeleton_arm(with_bow=true);
    translate([0, 0, 44.5]) light_weapon();
    translate([0, 0, 48]) light_armor();
  }
}

if (mode == 0) {
  skeleton_preview();
}

if (mode == 1) {
  skeleton_body();
  translate([0, 35, 0]) base();
  translate([0, -30, 0]) skeleton_head();
}

if (mode == 2) {
  skeleton_arm(with_bow=true);
}