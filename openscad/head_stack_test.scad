use <common.scad>
use <head.scad>

creeper_head();
translate([0, 40, 0]) light_armor();
translate([40, 0, 0]) heavy_armor();
translate([40, 40, 0]) light_weapon();
translate([80, 0, 0]) heavy_weapon();
translate([80, 40, 0]) status_effect();
