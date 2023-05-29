use <base.scad>
use <head.scad>

// Blocks with lugs on top.
repeatx(2, 50) {
  difference() {
    union() {
      chamfered_box([8, 8, 8]);
      translate([0, 0, 8]) locking_lug();
    }
    locking_socket_bottom();
  }
}

translate([0, 50, 0]) {
  repeatx(2, 50) {
    difference() {
      chamfered_box([8, 8, 8]);
      translate([0, 0, 8]) locking_socket_top();
      locking_socket_bottom();
    }
  }
}

// Locking pins.
translate([0, -40, 0])
  repeatx(3, 20)
    locking_pin();
