use <base.scad>
use <body.scad>
use <head.scad>

// 1 for the large pieces, 2 for the arms.
run = 2;

// Number of copies to print.
n = 3;

if (run == 1) {
  repeatx(n, 50) {
    basic_body(outstretched_arms=[false,true], bony=true);
    translate([0, 35, 0]) base();
    translate([0, -30, 0]) skeleton_head();
  }
}

if (run == 2) {
  repeatx(n, 20) {
    arm();
    bow();
    translate([0, 30, 0]) arm();
  }
}