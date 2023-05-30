include <common.scad>
use <base.scad>
use <head.scad>

arm_girth = 8;

torso_breadth = 18;
torso_thickness = 10;
torso_height = 18;

leg_height = 13;
leg_girth = 9;

module basic_body(zombie_arms=false, bony=false) {
  difference() {
    union() {
      // Torso.
      if (bony) {
        // Ribs.
        for (a = [0:2])
          translate([0, 0, a*torso_height/5])
            chamfered_box(
              [torso_breadth, torso_thickness, torso_height/5]);
        // The rest of the torso is narrower.
        chamfered_box(
          [torso_breadth-2, torso_thickness-2, torso_height]);
      } else {
        chamfered_box(
          [torso_breadth, torso_thickness, torso_height]);
      }

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
    locking_socket_bottom();
    
    // Arm locking sockets.
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        if (zombie_arms) {
          translate([
            (torso_breadth+arm_girth)/2,
            -arm_girth/2,
            arm_girth/2
          ])
            locking_socket_top();
        } else {
          translate([(torso_breadth+arm_girth)/2, 0, arm_girth])
            locking_socket_top();
        }
      }
    }
        
    // Baseplate locking socket.
    translate([0, 0, torso_height+leg_height])
      locking_socket_top();
  }
}

module arm() {
  chamfered_box([arm_girth, arm_girth, 12]);
  
  // Locking lug.
  translate([0, 0, 12])
    locking_lug();
}

module bow() {
  thickness = 3;
  piece_length = 8;

  translate([0, 0, 0])
    chamfered_box([thickness, piece_length*2, thickness]);
  for (a = [-1, 1])
    scale([1, a, 1])
      translate([0, piece_length-1, 0])
        rotate([45, 0, 0])
          translate([0, piece_length/2, -0.5])
            chamfered_box([thickness, piece_length, thickness]);
}

// Skeleton body prototype.
basic_body(bony=true);