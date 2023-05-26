include <common.scad>
use <base.scad>
use <head.scad>

zombie_arms = false;

translate([0, 0, 10.5]) {
  // Torso.
  torso_height = 18;
  translate([0, 0, 13])
    chamfered_box([18, 10, torso_height]);

  // Shoulders.
  translate([0, 0, 23])
    chamfered_box([34, 8, 8]);

  // Arms down at sides.
  arm_length = 12;
  for (a = [-1, 1]) {
    scale([a, 1, 1]) {
      if (zombie_arms) {
        translate([13, -10, 23])
          chamfered_box([8, arm_length, 8]);
      } else {
        translate([13, 0, 11])
          chamfered_box([8, 8, arm_length]);
      }
    }
  }

  // Legs.
  leg_height = 13;
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([4.5, 0, 0])
        chamfered_box([9, 9, leg_height]);

  // Head with 2 chips.
  translate([0, 0, 31]) {
    zombie_head();
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