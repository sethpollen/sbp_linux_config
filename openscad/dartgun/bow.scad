include <common.scad>

tube_wall = 3;
tube_id = spring_od + snug;
tube_od = tube_id + 2*tube_wall;

axle_diameter = 5;

wheel_diameter = axle_diameter + 2*spring_od + 3*tube_wall;
wheel_thickness = string_diameter + 1.5;

axle_plate_thickness = 4;

axle_cap_thickness = 2;
axle_cap_diameter = axle_diameter + 3;

// The axle is split into two pieces glued end-to-end into the follower.
axle_split = 1.5;

// The fingers which go through the tube walls and connect to the followers.
finger_width = 8;

module wheel() {
  difference() {
    rotate_extrude() {
      difference() {
        square([wheel_diameter/2, wheel_thickness]);
        translate([wheel_diameter/2 + string_diameter*0.17, wheel_thickness/2])
          octagon(string_diameter);
      }
    }
    
    translate([0, 0, -eps])
      flare_cylinder(wheel_thickness+2*eps, axle_diameter/2+snug, -foot);
  }
}

// 'piece' should be 1 or 2. 1 is the longer piece.
module axle(piece) {
  length =
    piece == 1
    ? wheel_thickness + 2*axle_plate_thickness + axle_cap_thickness - axle_split
    : axle_cap_thickness + axle_split;
  
  flare_cylinder(length, axle_diameter/2, foot);
  flare_cylinder(axle_cap_thickness, axle_cap_diameter/2, foot);
}

// TODO: let's start with just two springs on each side. One spring seems almost strong
// enough to launch a dart on its own. Four springs might be enough for the whole string
// assembly, if the followers and wheels are small and light.

module tube() {
  difference() {
    // Tube exterior.
    linear_extrude(spring_max_length) {
      difference() {
        octagon(tube_od);
        circle_ish((spring_od + snug)/2);
      }
    }
    
    // Finger slot. Make this very loose.
    finger_slot_width = finger_width + 1;
    finger_slot_length = tube_wall*3;
    translate([-finger_slot_width/2, spring_od/2-tube_wall, spring_min_length])
      cube([finger_slot_width, finger_slot_length, spring_max_length]);
  }
}

tube();