include <common.scad>
use <base.scad>
use <head.scad>

// TODO: these lugs are probably off center.

arm_girth = 8;
leg_girth = 9;

module basic_body(zombie_arms=false) {
  difference() {
    torso_breadth = 18;
    torso_height = 18;
    leg_height = 13;

    union() {
      // Torso.
      chamfered_box([torso_breadth, 10, torso_height]);

      // Shoulders.
      chamfered_box([
        torso_breadth + arm_girth*2, arm_girth, arm_girth]);

      // Legs.
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([leg_girth/2, 0, torso_height])
            chamfered_box([leg_girth, leg_girth, leg_height]);
    }
    
    // Head locking socket.
    locking_socket();
    
    // Arm locking sockets.
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        if (zombie_arms) {
          translate([
            (torso_breadth+arm_girth)/2,
            -arm_girth/2,
            arm_girth/2
          ])
            rotate([-90, 0, 0])
              locking_socket();
        } else {
          translate([(torso_breadth+arm_girth)/2, 0, arm_girth])
            scale([1, 1, -1])
              locking_socket();
        }
      }
    }
        
    // Baseplate locking socket.
    translate([0, 0, torso_height+leg_height])
      scale([1, 1, -1])
        locking_socket();
  }
}

module arm(length=12) {
  chamfered_box([arm_girth, arm_girth, length]);
  
  // Locking lug.
  translate([0, 0, length])
    locking_lug();
}
