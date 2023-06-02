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
    translate([0, 0, 44.5]) rotate([0, 180, 0]) enderman_body();
    translate([0, 0, 44.5]) enderman_head();
    translate([13, 0, 14.5]) enderman_arm();
    translate([-13, 0, 14.5]) enderman_arm();
    translate([0, 0, 54.5]) light_weapon();
    translate([0, 0, 58]) light_armor();
  }
}

if (mode == 0) {
  enderman_preview();
}