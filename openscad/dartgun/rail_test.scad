include <common.scad>
include <rail.scad>

module one() {
  translate([0, 0, rail_notch_depth])
    rotate([-90, 0, 0])
      rail(10, 20, 5);
}

extra = 0.6;

module two() {
  translate([0, 0, 9]) {
    rotate([180, 0, 0]) {
      difference() {
        translate([10, 0, 4.5])
          cube([16, 10, 9], center=true);
        translate([0, 0, -extra])
          rotate([0, 90, 0])
            rail(10, 20, 5, cavity=true);
      }
    }
  }
}

translate([-10, -3, 0]) one();
translate([0, 0, 0]) two();
translate([0, 13, 0]) two();