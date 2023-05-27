include <common.scad>
use <base.scad>
use <body.scad>
use <head.scad>

// Bring everything together to build a printable design.

translate([-30, 0, 0]) {
  difference() {
    base_chip();
    locking_socket(bottom=true);
  }
  translate([0, 50, 0]) {
    difference() {
      base_chip();
      locking_socket(bottom=true);
    }
  }
}

translate([0, 15, 0]) {
  arm();
  translate([0, 15, 0]) {
    arm();
  }
}
