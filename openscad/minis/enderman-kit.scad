use <base.scad>
use <body.scad>
use <head.scad>

// 0 for preview.
mode = 0;

module enderman_arm() {
  arm(tall=true, bony = true);
}

module enderman_body() {
  basic_body(tall=true);
}

module enderman_preview() {
  color(c = [0.4, 0.4, 0.4]) {
    translate([0, 0, 0]) base();
    translate([0, 0, 42]) rotate([0, 180, 0]) enderman_body();
    translate([0, 0, 42]) enderman_head();
    translate([13, 0, 16]) enderman_arm();
    translate([-13, 0, 16]) enderman_arm();
    translate([0, 0, 52]) light_weapon();
    translate([0, 0, 55.5]) light_armor();
  }
}

if (mode == 0) {
  enderman_preview();
}