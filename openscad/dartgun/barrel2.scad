include <common.scad>

// 120 is about the limit of the cams.
stroke = 110;
trigger_width = 8;
trigger_cavity_width = trigger_width + extra_loose;
trigger_cavity_length = 45;

barrel_length = 250;

// Tall enough for the string.
//
// TODO: Consider making this slightly wider, to avoid friction with string.
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

zip_channel_height = 3.2;
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
  
  if (trigger_slot) {
    // Add a bridge (where it won't hit the trigger) to keep things spaced.
    bridge_width = trigger_cavity_width + 2;
    hull() {
      translate([-bridge_width/2, 0, 0]) {
        cube([bridge_width, eps, 7]);
        translate([0, 20, 0])
          cube([bridge_width, eps, 1]);
      }
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

module slider(length, slot=7.5, zip_channels=[], zip_orientation=true) {
  difference() {
    union() {
      difference() {
        cube([slider_width, length, slider_height], center=true);
        
        // Add 0.1 to the horizontal clearance, since we are bolting these parts
        // together tightly.
        cube([barrel_width + loose + 0.1, length + 1, barrel_height + loose], center=true);
        
        // Carve out corners, in case the printer cuts corners.
        for (x = barrel_width * [-0.5, 0.5], z = barrel_height * [-0.5, 0.5])
          translate([x, 0, z])
            rotate([0, 45, 0])
              cube([0.9, length + 1, 0.9], center=true);
        
        // Slot for lug on the end of the barrel.
        translate([0, length/2 - slot, 0]) {
          cube([
            barrel_width + 2*barrel_lug_x + snug,
            barrel_lug_y + snug + 0.1,  // Add 0.1 to account for inaccuracies in bridging.
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
  
    // Zip tie channel.
    for (y = zip_channels) {
      translate([0, zip_channel_width/2 - length/2 + y, 0]) {
        if (zip_orientation) {
          rotate([90, 0, 0]) {
            linear_extrude(zip_channel_width) {
              difference() {
                offset(slider_wall + zip_channel_height)
                  square([barrel_width - slider_wall - 2, barrel_height + eps], center=true);
                offset(slider_wall)
                  square([barrel_width - slider_wall - 2, barrel_height + eps], center=true);
              }
            }
          }
        } else {
          rotate([90, 0, 0]) {
            linear_extrude(zip_channel_width) {
              difference() {
                offset(slider_wall + zip_channel_height)
                  square([barrel_width + eps , barrel_height - slider_wall - 2], center=true);
                offset(slider_wall)
                  square([barrel_width + eps, barrel_height - slider_wall - 2], center=true);
              }
            }
          }
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
