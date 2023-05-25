include <common.scad>

module ring() {
  rotate_extrude(angle=360)
    translate([12, 0, 0])
      polygon([
        [0, 0],
        [3, 0],
        [3, 1.2],
        [2.5, 1.7],
        [0.5, 1.7],
        [0, 1.2],
      ]);
}

module ring_hole() {
  loose_hole()
    ring();
}

module base() {
  difference() {
    chamfered_disk(3.5, 20);
    ring_hole();
  }
}

module base_chip() {
  base();
  translate([0, 0, 3.5])
    ring();
}

// TODO:
translate([0, 0, 10]) base();
base_chip();