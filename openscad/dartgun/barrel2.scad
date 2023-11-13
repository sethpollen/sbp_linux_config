include <common.scad>

// 120 is about the limit of the cams.
stroke = 110;
trigger_width = 8;
trigger_cavity_width = 8.5;
trigger_cavity_length = 20;

barrel_length = 220;

// Tall enough for the string.
//
// TODO: increase slightly. Right now the string has a bit of friction.
// Perhaps increase to 4.4.
barrel_gap = 4;

// Should be wide enough to accommodate whatever bore structure we
// want.
barrel_width = 22;
barrel_height = 33;

slider_wall = 7;
slider_width = barrel_width + 2*slider_wall;
slider_height = barrel_height + 2*slider_wall;

barrel_lug_x = 3;
barrel_lug_y = 5;

// Tested with several darts.
main_bore = 13.8;

zip_channel_height = 2.4;
zip_channel_width = 6.5;

module barrel(trigger_slot=false) {
  // Make the bore with high precision.
  $fa = 5;
  
  difference() {
    union() {
      // Main length.
      translate([-barrel_width/2, 0, 0])
        cube([barrel_width, barrel_length, barrel_height/2 - barrel_gap/2]);
      
      // Lugs on one end for attaching to a fixed piece.
      translate([-barrel_width/2 - barrel_lug_x, 0, 0])
        cube([barrel_width + barrel_lug_x*2, barrel_lug_y, barrel_height/2 - barrel_gap/2]);
    }
    
    // Bore.
    translate([0, -eps, barrel_height/2])
      rotate([-90, 0, 0])
        cylinder(barrel_length+2*eps, d=main_bore);
            
    // Outside foot chamfers.
    for (x = barrel_width/2 * [-1, 1])
      translate([x, 0, 0])
        rotate([0, 45, 0])
          cube([sqrt(0.32), barrel_length*2+eps, sqrt(0.32)], center=true);
    
    if (trigger_slot) {
      // Trigger slot.
      translate([-trigger_cavity_width/2, -eps, -eps])
        cube([trigger_cavity_width, trigger_cavity_length, barrel_height]);  

      // Inside foot chamfers.
      for (x = trigger_cavity_width/2 * [-1, 1])
        translate([x, trigger_cavity_length/2, 0])
          rotate([0, 45, 0])
            cube([sqrt(0.32), trigger_cavity_length, sqrt(0.32)], center=true);
    }
  }
    
  // Brims to prevent warping.
  brim_lip_x = 7;
  brim_lip_y = 5;
  brim_thickness = 0.4;
  difference() {
    translate([-barrel_width/2-brim_lip_x, -brim_lip_y, 0])
      cube([barrel_width + 2*brim_lip_x, barrel_length + 2*brim_lip_y, brim_thickness]);
    translate([-barrel_width/2-brim_lip_x - 0.5, brim_lip_y, -eps])
      cube([barrel_width + 2*brim_lip_x + 1, barrel_length - 2*brim_lip_y, 1]);
  }
}

module slider(length, zip_channel=true) {
  difference() {
    cube([slider_width, length, slider_height], center=true);
    cube([barrel_width + loose, length + 1, barrel_height + loose], center=true);

    // Zip tie channel.
    if (zip_channel) {
      translate([0, zip_channel_width/2, 0]) {
        rotate([90, 0, 0]) {
          linear_extrude(zip_channel_width) {
            difference() {
              offset(slider_wall + zip_channel_height)
                square([barrel_width - slider_wall - 1, barrel_height + eps], center=true);
              offset(slider_wall)
                square([barrel_width - slider_wall - 1, barrel_height + eps], center=true);
            }
          }
        }
      }
    }
    
    // Slot for lug on the end of the barrel.
    translate([0, length/2 - barrel_lug_y*1.5, 0]) {
      cube([
        barrel_width + 2*barrel_lug_x + snug,
        barrel_lug_y + snug,
        barrel_height + loose
      ], center=true);
    }
  }

  // Lugs which slide between two barrel halves.
  lug_height = barrel_gap - snug;
  lug_intrusion = 3;
  difference() {
    cube([slider_width, length, lug_height], center=true);
    cube([barrel_width - 2*lug_intrusion, length + 1, lug_height + 1], center=true);
    
    // End chamfers.
    for (y = length/2 * [-1, 1], z = lug_height/2 * [-1, 1])
      translate([0, y, z])
        rotate([45, 0, 0])
          cube([slider_width, 1.5, 1.5], center=true);
    
    // Length chamfers.
    for (x = (barrel_width - 2*lug_intrusion)/2 * [-1, 1], z = lug_height/2 * [-1, 1])
      translate([x, 0, z])
        rotate([0, 45, 0])
          cube([1, length, 1], center=true);
  }
}

module slider_print() {
  for (a = [0]) {
    rotate([90, 0, a]) {
      translate([2, 0, 0]) {
        intersection() {
          slider(15, false);
          translate([0, -100, -100])
            cube(200);
        }
      }
    }
  }
}

module barrel_print() {
  barrel();
  translate([barrel_width + barrel_lug_x + 2, barrel_length, 0])
    rotate([0, 0, 180])
      barrel();
}

slider_print();
