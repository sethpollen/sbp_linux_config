include <common.scad>
use <base.scad>
use <head.scad>

// TODO: these lugs are probably off center.

module basic_body(zombie_arms=true) {
  difference() {
    torso_breadth = 18;
    torso_height = 18;
    leg_height = 13;
    shoulder_height = 10;

    union() {
      // Torso.
      chamfered_box([torso_breadth, 10, torso_height]);

      // Shoulders.
      chamfered_box([
        torso_breadth*2, shoulder_height, shoulder_height]);

      // Legs.
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([4.5, 0, torso_height])
            chamfered_box([9, 10, leg_height]);
      
      // Baseplate locking lug.
      translate([0, 0, torso_height+leg_height])
        locking_lug();
      // Fill in the chamfer between the feet and the lug.
      translate([0, 0, torso_height+leg_height-1])
        locking_lug();
    }
    
    // Head locking socket.
    locking_socket();
    
    // Arm locking sockets.
    for (a = [-1, 1]) 
      scale([a, 1, 1])
        if (zombie_arms) {
          translate([
            torso_breadth/2+4.5,
            -shoulder_height/2,
            shoulder_height/2
          ])
            rotate([90, 0, 0])
              scale([1, 1, -1])
                locking_socket();
        } else {
          translate([torso_breadth/2+4.5, 0, shoulder_height])
            scale([1, 1, -1])
              locking_socket();
        }
  }
}

module arm(length=12) {
  chamfered_box([9, 9, length]);
  
  // Locking lug.
  translate([0, 0, length])
    locking_lug();
}

basic_body();

// Print a pair of arms.
translate([30, 0, 0]) {
  arm();
  translate([20, 0, 0]) {
    arm();
  }
}
