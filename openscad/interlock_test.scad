use <base.scad>
use <head.scad>

// Test the loose interface on top of the head.
repeatx(2, 30) head_chip();

// Test the loose interface under the base.
translate([0, 40, 0]) {
  repeatx(2, 50) {
    difference() {
      base_chip();
      
      // Insert some locking sockets in convenient flat places.
      translate([5, 0, 0])
        locking_socket_bottom();
      translate([0, 0, 3.5])
        locking_socket_top();
    }
  }
}

// Locking lugs.
translate([0, -25, 0]) {
  repeatx(2, 20) {
    difference() {
      union() {
        chamfered_box([8, 8, 8]);
        translate([0, 0, 8]) locking_lug();
      }
      locking_socket_bottom();
    }
  }
}

// Locking pins.
translate([0, -40, 0])
  repeatx(2, 20)
    locking_pin();
