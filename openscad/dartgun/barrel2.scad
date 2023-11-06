include <common.scad>

// 120 is about the limit of the cams.
stroke = 110;
trigger_width = 8;
trigger_cavity_width = 8.5;
trigger_cavity_length = 20;

barrel_length = 220;

// Tall enough for the string.
barrel_gap = 4;

// Should be wide enough to accommodate whatever bore structure we
// want.
barrel_width = 22;
barrel_height = 33;

slider_wall = 4;
slider_width = barrel_width + 2*slider_wall;
slider_height = barrel_height + 2*slider_wall;

barrel_lug_x = 3;
barrel_lug_y = 5;

// Tested with several darts.
main_bore = 13.8;

module barrel(trigger_slot=true) {
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
  difference() {
    translate([-barrel_width/2-brim_lip_x, -brim_lip_y, 0])
      cube([barrel_width + 2*brim_lip_x, barrel_length + 2*brim_lip_y, 0.4]);
    translate([-barrel_width/2-brim_lip_x - 0.5, brim_lip_y, -eps])
      cube([barrel_width + 2*brim_lip_x + 1, barrel_length - 2*brim_lip_y, 1]);
  }
}

module slider(length) {
  difference() {
    cube([slider_width, length, slider_height], center=true);
    translate([0, 0, 0])
      cube([barrel_width + loose, length + eps, barrel_height + loose], center=true);
  }
  
  // Lugs which slide between two barrel halves.
  lug_height = barrel_gap - snug;
  lug_intrusion = 2.5;
  difference() {
    cube([slider_width, length, lug_height], center=true);
    cube([barrel_width - 2*lug_intrusion, length + eps, lug_height + eps], center=true);
    
    // End chamfers.
    for (y = length/2 * [-1, 1], z = lug_height/2 * [-1, 1])
      translate([0, y, z])
        rotate([45, 0, 0])
          cube([slider_width, 1, 1], center=true);
    
    // Length chamfers.
    for (x = (barrel_width - 2*lug_intrusion)/2 * [-1, 1], z = lug_height/2 * [-1, 1])
      translate([x, 0, z])
        rotate([0, 45, 0])
          cube([0.6, length, 0.6], center=true);
  }
}

translate([0, 0, barrel_height/2]) slider(50);
barrel();