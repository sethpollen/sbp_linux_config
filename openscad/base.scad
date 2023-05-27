include <common.scad>

module ring() {
  rotate_extrude(angle=360)
    translate([12, 0, 0])
      polygon([
        [0, 0],
        [3, 0],
        [3, 1.1],
        [2.5, 1.6],
        [0.5, 1.6],
        [0, 1.1],
      ]);
}

module ring_hole() {
  loose_hole()
    ring();
}

module base(lug=true) {
  difference() {
    union() {
      chamfered_disk(3.5, 20);
      
      // A lug for gluing a body.
      if (lug)
        translate([0, 0, 3.5])
          locking_lug();
    }
    ring_hole();
  }
}

module base_chip() {
  base(lug=false);
  translate([0, 0, 3.5])
    ring();
}

// Demo.
base();