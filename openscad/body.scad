include <common.scad>
use <base.scad>
use <head.scad>

translate([0, 0, 10.5]) {
  // Torso.
  translate([0, 0, 14])
    chamfered_box([18, 10, 18]);

  // Shoulders.
  translate([0, 0, 24])
    chamfered_box([34, 8, 8]);

  // Arms down at sides.
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([13, 0, 12])
        chamfered_box([8, 8, 12]);

  // Legs.
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([4.5, 0, 0])
        chamfered_box([9, 9, 14]);

  // Head with 2 chips.
  translate([0, 0, 32]) {
    skeleton_head();
    translate([0, 0, 10]) {
      chip();
      translate([0, 0, 3.5]) {
        chip();
      }
    }
  }
}

translate([0, 0, 7])
  base();
translate([0, 0, 3.5])
  base_chip();
translate([0, 0, 0])
  base_chip();