use <base.scad>
use <body.scad>
use <head.scad>

// 0 for preview.
// 1 for the large pieces.
// 2 for the arms.
mode = 0;

// Number of copies to print.
n = 3;

module skeleton_arm(with_bow=false) {
  arm(bony=true);
  if (with_bow) {
    bow();
  }
}

module skeleton_body() {
  basic_body(outstretched_arms=[false,true], bony=true);
}

module skeleton_preview() {
  color(c = [0.8, 0.8, 0.8]) {
    translate([0, 0, 0]) base();
    translate([0, 0, 34.5]) rotate([0, 180, 0]) skeleton_body();
    translate([0, 0, 34.5]) skeleton_head();
    translate([13, 0, 14.5]) skeleton_arm();
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
  repeatx(n, 50) {
    skeleton_body();
    translate([0, 35, 0]) base();
    translate([0, -30, 0]) skeleton_head();
  }
}

if (mode == 2) {
  repeatx(n, 20) {
    skeleton_arm(with_bow=true);
    translate([0, 30, 0]) skeleton_arm();
  }
}