use <base.scad>
use <body.scad>
use <head.scad>

basic_body(outstretched_arms=[true,false], bony=true);

translate([25, 20, 0]) {
  arm(bony=true);
  bow();
}

translate([40, 20, 0]) arm(bony=true);

translate([0, 30, 0]) skeleton_head();
translate([-30, 30, 0]) heavy_weapon();
translate([-60, 30, 0]) light_armor();

translate([-50, -10, 0]) base();
translate([-50, -60, 0]) base_chip();
translate([0, -40, 0]) base_chip();
