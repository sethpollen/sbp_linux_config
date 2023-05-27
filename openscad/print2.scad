include <common.scad>
use <base.scad>
use <body.scad>
use <head.scad>

// Heads need different support structure settings.

zombie_head();
translate([30, 0, 0]) {
  steve_head();
}
