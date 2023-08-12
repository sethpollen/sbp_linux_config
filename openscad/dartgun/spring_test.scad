include <common.scad>

wall = 1.5;
base = 3;
exterior_diameter = spring_od+wall*2;
extra_tube_length = 10;
follower_length = 13;
finger_width = 4;

module tube() {
  translate([0, 0, spring_od/2+wall]) {
    rotate([90, 0, 0]) {
      difference() {
        // Tube.
        linear_extrude(spring_max_length + extra_tube_length) {
          difference() {
            octagon(exterior_diameter);
            circle_ish((spring_od + snug)/2);
          }
        }
        
        // Finger slot.
        translate([-(finger_width+loose)/2, 0, spring_min_length])
          cube([
            finger_width+loose,
            spring_od,
            spring_max_length + extra_tube_length
          ]);
      }
      
      // End cap.
      translate([0, 0, -base])
        linear_extrude(base)
          octagon(exterior_diameter);
    }
  }
}

module follower() {
  difference() {
    // Exterior.
    union() {
      flare_cylinder(follower_length, spring_od/2, foot);
      translate([0, -finger_width/2, 0])
        flare_cube([spring_od, finger_width, follower_length], foot);
    }
    
    // Cutout to save volume.
    translate([0, 0, base])
      cylinder(follower_length, d=spring_od-wall*2);
  }
  
  // Adhesion aid.
  translate([spring_od, -(finger_width)/2, 0])
    cube([4-brim_offset, finger_width, 0.2]);
  translate([spring_od+1, -(finger_width)/2, 0])
    cube([0.5, finger_width, 2]);
}

tube();
translate([20, -20, 0]) follower();