include <common.scad>
include <clips.scad>

main_bore = 13.8;
constricted_bore = main_bore - 0.5;

// In my early prints this was 4, but there was still some dart mangling
// when the string rose too high while pushing the dart. The theoretical
// limit here is probably about 3.
barrel_gap = 3.4;

mag_height = 63;
mag_wall = 11.2;

barrel_width = main_bore + 2 * mag_wall;
barrel_height = 35;

mag_floor = 1.8;
mag_inner_wall = 2.2;

arm_pivot_diam = nail_diameter + 5;
arm_pivot_cav_diam = arm_pivot_diam + extra_loose;
arm_pivot_xy = [main_bore/2 + mag_inner_wall + arm_pivot_cav_diam/2, 50];
arm_outer_circle_radius = arm_pivot_xy.y - barrel_gap/2 - mag_floor;
arm_outer_circle_clearance = 0.4;

// Make sure the whole arm fits well within the mag wall.
assert(mag_wall > mag_inner_wall + arm_pivot_cav_diam + 0.2);

arm_bottom_opening_height = 6.5;
arm_bore_intrusion = 3.5;
max_arm_swing = 7;  // Degrees.

trunnion_width = 3;
trunnion_length = 5;

trigger_width = 8;
trigger_cav_width = trigger_width + extra_loose;

enclosure_wall = 7;

module build_plate_chamfer() {
  rotate([0, 0, 45])
    square(0.7, center=true);
}

module bore_2d(constriction) {
  // The bore needs to fit the dart nicely.
  $fn = 70;
  
  diam = constriction ? constricted_bore : main_bore;
  circle(d = diam);
  
  // Ensure nice bridging if we print the bore cavity facing down.
  square([2.4, diam], center=true);

  if (constriction) {
    intersection() {
      circle(d=main_bore);
      hull() {
        a = 45;
        square(constricted_bore * [cos(a), sin(a)], center=true);
        square([constricted_bore * (cos(a) + 1.2*sin(a)), eps], center=true);
      }
    }
  }
  
  // Chamfer the bore edge of the barrel top.
  for (a = [-1, 1])
    scale([a, 1])
      translate([main_bore/2-1.3, barrel_gap/2])
        rotate([0, 0, 45])
          square(2, center=true);
}

MAG_NONE = 0;
MAG_END = 1;
MAG_MIDDLE = 2;
MAG_SUPPORT = 3;  // Interior wall.

module barrel_2d(mag=MAG_NONE, trunnion=false, trigger_cav=false, constriction=false) {
  width = barrel_width + (trunnion ? trunnion_width*2 : 0);
  top = (mag == MAG_NONE) ? barrel_height/2 : mag_height;
  bottom = -barrel_height/2;
  
  difference() {
    translate([-width/2, bottom]) 
      square([width, top - bottom]);
    
    bore_2d(constriction);

    // Build plate chamfers.
    for (x = width/2 * [-1, 1]) {
      for (y = [bottom, top, -barrel_gap/2, barrel_gap/2])
        translate([x, y])
          build_plate_chamfer();
    
      if (mag != MAG_END)
        translate([x, barrel_height/2])
          build_plate_chamfer();
    }
    
    // String gap.
    translate([-barrel_width/2 - trunnion_width - eps, -barrel_gap/2])
      square([barrel_width + 2*eps + 2*trunnion_width, barrel_gap]);
    
    if (mag == MAG_MIDDLE || mag == MAG_SUPPORT) {
      // Cut out the slot for holding the darts.
      translate([-main_bore/2, 0])
        square([main_bore, top+1]);
      
      // Build plate chamfers.
      for (x = main_bore/2 * [-1, 1])
        translate([x, barrel_gap/2])
          build_plate_chamfer();
      
      // Chamfers at the loading orifice.
      orifice_chamfer = 8;
      for (a = [-1, 1]) {
        scale([a, 1]) {
          translate([main_bore/2, top]) {
            difference() {
              square(orifice_chamfer, center=true);
              translate(orifice_chamfer/2 * [1, -1])
                circle(d=orifice_chamfer);
            }
          }
        }
      }
    }
    
    // Arm cavities.
    for (a = [-1, 1]) {
      scale([a, 1]) {
        cavity_width = mag_wall - mag_inner_wall;
        
        cavity_floor = (mag == MAG_END || mag == MAG_NONE) 
          ? barrel_height/2
          : barrel_gap/2 + mag_floor;
        
        cavity_top_steeple_height = cavity_width*0.75;

        // Allow the edges of the floor to rise, following the curve of the arm.
        cavity_floor_lift = 1;

        cavity_ceiling = (mag == MAG_END)
          ? arm_pivot_xy.y - cavity_top_steeple_height - retention_clip_width/2
          : arm_pivot_xy.y + arm_pivot_cav_diam/2;        
        
        translate([main_bore/2, 0]) {
          // Columnar part of the cavity.
          translate([mag_inner_wall, 0]) {
            hull() {
              // Flare the bottom for good support.
              if (mag == MAG_MIDDLE)
                translate([0, cavity_floor + cavity_floor_lift])
                  square([cavity_width, eps]);
              else
                translate([cavity_width, cavity_floor + cavity_floor_lift])
                  square(eps);  
              
              // Make sure the flare goes all the way up to the top of the MAG_MIDDLE
              // wall chamfer.
              translate([
                0,
                (mag == MAG_SUPPORT)
                  ? (cavity_floor + arm_bottom_opening_height + 2)
                  : (barrel_height/2 + enclosure_wall)
              ])
                square([mag_wall, eps]);
              translate([0, cavity_ceiling])
                square([mag_wall, eps]);
              
              // Steeple the top to allow printing.
              translate([cavity_width, cavity_ceiling + cavity_top_steeple_height])
                square([eps, eps]);
            }
            
            // Chamfer the inside of the inner wall.
            if (mag == MAG_MIDDLE)
              translate([0, cavity_floor + arm_bottom_opening_height])
                rotate([0, 0, 45])
                  square(mag_inner_wall * sqrt(2), center=true);
          }
          
          // Opening towards the inside.
          if (mag == MAG_MIDDLE)
            translate([0, cavity_floor + cavity_floor_lift])
              square([mag_wall, arm_bottom_opening_height - cavity_floor_lift]);
        }
        
        if (mag == MAG_MIDDLE) {
          translate(arm_pivot_xy) {
            difference() {
              $fn = 100;
              circle(arm_outer_circle_radius);
              circle(arm_outer_circle_radius - cavity_floor_lift);
            }
          }
        }
      }
    }
    
    if (mag == MAG_END)
      for (a = [-1, 1])
        scale([a, 1])
          translate(arm_pivot_xy)
            octagon(nail_loose_diameter);
    
    if (trigger_cav) {
      translate([0, bottom])
        square([trigger_cav_width, barrel_height], center=true);

      for (x = trigger_cav_width/2 * [-1, 1])
        translate([x, bottom])
          build_plate_chamfer();
    }
  }
}

// A pair of horizontal bars giving the slotted area of the mag front. Hand tuned.
mag_front_slot_height = 7.5;
mag_front_slot_floor = barrel_height/2 + enclosure_wall + 1.1;

module mag_front_slot_2d() {
  width = 80; 
  
  difference() {
    translate([-width/2, mag_front_slot_floor])
      square([width, mag_front_slot_height]);
    
    square([2 * (arm_pivot_xy.x - arm_pivot_diam/2), 200], center=true);
  }
}

module arm_outer_circle_2d(retract=true) {
  $fn = 100;
  translate(arm_pivot_xy)
    circle(arm_outer_circle_radius - arm_outer_circle_clearance);
}

module arm_inner_circle_2d() {
  clearance = 0.8;
  $fn = 100;
  translate(arm_pivot_xy)
    circle(clearance + norm(
      arm_pivot_xy
      - [main_bore/2, barrel_gap/2 + mag_floor + arm_bottom_opening_height]
    ));
}

module arm_outer_ring_2d(x1, x2) {
  $fn = 100;

  intersection() {
    // A ring which passes through the bottom opening.
    difference() {
      arm_outer_circle_2d();
      arm_inner_circle_2d();
    }
  
    // Just take a small slice of the ring.  
    translate([x1, 0])
      square([x2 - x1, 80]);
  }
}

module arm_rod_2d() {
  intersection() {
    hull() {
      // Ring around the pin. Round off the part which gets close to the
      // mag inner wall.
      translate(arm_pivot_xy) {
        circle(d=arm_pivot_diam);
        
        rotate([0, 0, -max_arm_swing]) {
          intersection() {
            octagon(arm_pivot_diam);
            translate([arm_pivot_diam/2, 0])
              square(arm_pivot_diam, center=true);
          }    
        }  
      }
      
      // End of arm.
      translate([arm_pivot_xy.x, barrel_gap/2 + mag_floor + arm_pivot_cav_diam/2])
        square(arm_pivot_diam, center=true);
    }
    
    translate(arm_pivot_xy)
      rotate([0, 0, -max_arm_swing])
        square([arm_pivot_diam, arm_pivot_xy.y * 3], center=true);
  }
}

module arm_2d(mag, finger_intrusion=0, band_channel=false) {
  if (mag == MAG_END || mag == MAG_NONE) {
    hull() {
      intersection() {
        arm_rod_2d();
        mag_front_slot_2d();
        
        if (mag == MAG_NONE)
          translate([
            arm_pivot_xy.x + mag_front_slot_height/2 - finger_intrusion - 0.3,
            mag_front_slot_floor + mag_front_slot_height/2
          ])
            if (band_channel)
              circle(d=mag_front_slot_height);
            else
              translate([1, 0])
                square(mag_front_slot_height, center=true);
      }
      
      if (mag == MAG_NONE) {
        translate([arm_pivot_xy.x - finger_intrusion, mag_front_slot_floor + mag_front_slot_height/2]) {
          intersection() {
            circle(d=mag_front_slot_height);
            translate([-mag_front_slot_height/2, 0])
              square(mag_front_slot_height, center=true);
          }
        }
      }
    }
    
  } else {
    difference() {
      intersection() {
        arm_rod_2d();
        
        
        arm_outer_circle_2d();
      }
      
      // Pin hole.
      translate(arm_pivot_xy)
        rotate([0, 0, -max_arm_swing])
          octagon(nail_loose_diameter);
      
      // Remove the end of the arm, to avoid hitting the support flare.
      if (mag == MAG_SUPPORT)
        square([30, barrel_gap/2 + mag_floor + arm_bottom_opening_height + 4]);

      // Build plate chamfer.
      translate(arm_pivot_xy) {
        rotate([0, 0, -max_arm_swing]) {
          translate([arm_pivot_diam/2, -arm_outer_circle_radius + arm_outer_circle_clearance]) {
            difference() {
              chamfer = 3;
              square(chamfer*2, center=true);
              translate(chamfer * [-1, 1])
                circle(chamfer);
            }
          }
        }
      }
    }

    if (mag == MAG_MIDDLE) {
      // Fillet at wrist.
      translate(arm_pivot_xy + [0, barrel_gap/2 + mag_floor+ arm_bottom_opening_height - 1.5])
        rotate([0, 0, -5])
          translate([0, -arm_pivot_xy.y])
            rotate([0, 0, 45])
              square(3, center=true);
      
      // Intrusion on the end of the arm.
      difference() {
        arm_outer_ring_2d(
          main_bore/2 - arm_bore_intrusion,
          main_bore/2 + mag_inner_wall + 0.3
        );
        
        bore_2d();
        
        // 0.2 to lift the dart stack slightly.
        translate([0, main_bore + 0.2])
          bore_2d();
      }
    }
  }
}

barrel_back_wall = 20;
mag_front_back_wall = 6;
feed_cut_length = 74;
barrel_front_wall = 20;

barrel_total_length = barrel_back_wall + 2*mag_front_back_wall + feed_cut_length + barrel_front_wall;

mag_support_length = 7;
mag_support_count = 2;
mag_support_spacing =
  (feed_cut_length - (mag_support_count * mag_support_length)) /
  (mag_support_count + 1);

module barrel() {
  mag_clip1_xyz = [
    barrel_width/2,
    arm_pivot_xy.y - retention_plate_width/2,
    barrel_back_wall - retention_plate_thickness
  ];
  mag_clip1_r = [0, 0, 90];

  mag_clip2_xyz = [
    -barrel_width/2,
    arm_pivot_xy.y - retention_plate_width/2,
    barrel_back_wall + 2*mag_front_back_wall + feed_cut_length + retention_plate_thickness
  ];
  mag_clip2_r = [180, 0, 90];
  
  difference() {
    union() {
      linear_extrude(trunnion_length) barrel_2d(trigger_cav=true, trunnion=true);
      
      linear_extrude(barrel_back_wall) barrel_2d(trigger_cav=true);
      
      translate([0, 0, barrel_back_wall]) {
        linear_extrude(mag_front_back_wall) barrel_2d(mag=MAG_END);
        
        translate([0, 0, mag_front_back_wall]) {
          linear_extrude(feed_cut_length) barrel_2d(mag=MAG_MIDDLE);
                
          for (i = [1 : mag_support_count])
            translate([0, 0, i*mag_support_spacing + (i-1)*mag_support_length])
              linear_extrude(mag_support_length) barrel_2d(mag=MAG_SUPPORT);
          
          translate([0, 0, feed_cut_length]) {
            linear_extrude(mag_front_back_wall) barrel_2d(mag=MAG_END, constriction=true);
              
            translate([0, 0, mag_front_back_wall]) {
              linear_extrude(barrel_front_wall) barrel_2d();
            }
          }
        }
      }
    }
    
    // Nut holes.
    translate(mag_clip1_xyz)
      rotate(mag_clip1_r)
        retention_nut_hole(barrel_width);
    translate(mag_clip2_xyz)
      rotate(mag_clip2_r)
        retention_nut_hole(barrel_width);
  }
  
  // Pin retention clips.
  translate(mag_clip1_xyz)
    rotate(mag_clip1_r)
      retention_plate_clips(barrel_width);
  translate(mag_clip2_xyz)
    rotate(mag_clip2_r)
      retention_plate_clips(barrel_width);

  // Cross connection under the trigger.
  hull() {
    translate([-trigger_cav_width/2-2, -barrel_height/2, 0]) {
      cube([trigger_cav_width+4, 5, eps]);
      translate([0, 0, barrel_back_wall/2])
        cube([trigger_cav_width+4, 1, eps]);
    }
  }
}

arm_super_loose = 0.7;
finger_width = arm_bore_intrusion + mag_inner_wall;
finger_base = 7;
finger_length = finger_width * 2;

module arm() {
  for (i = [1 : mag_support_count])
    translate([0, 0, i*mag_support_spacing + (i-1)*mag_support_length - arm_super_loose/2])
      linear_extrude(mag_support_length + arm_super_loose) arm_2d(mag=MAG_SUPPORT);

  for (i = [1 : mag_support_count+1])
    translate([0, 0, (i-1)*mag_support_spacing + (i-1)*mag_support_length + arm_super_loose/2])
      linear_extrude(mag_support_spacing - arm_super_loose) arm_2d(mag=MAG_MIDDLE);

  translate([0, 0, arm_super_loose/2]) {
    linear_extrude(feed_cut_length + mag_front_back_wall)
      arm_2d(mag=MAG_END);
    
    translate([0, 0, feed_cut_length + mag_front_back_wall]) {
      linear_extrude(1)
        arm_2d(mag=MAG_NONE, finger_intrusion=finger_width);
      linear_extrude(finger_base)
          arm_2d(mag=MAG_NONE, finger_intrusion=finger_width, band_channel=true);

      hull() {
        translate([0, 0, finger_base-1])
          linear_extrude(1)
            arm_2d(mag=MAG_NONE, finger_intrusion=finger_width);
        
        translate([0, 0, finger_length])
          linear_extrude(finger_base)
            arm_2d(mag=MAG_NONE);
      }
    }
  }
}

module preview_2d(mag=MAG_END) {
  barrel_2d(mag=mag);
  arm_2d(mag=mag);
}

module preview() {
  barrel();
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([0, 0, barrel_back_wall + mag_front_back_wall])
        arm();
}

module barrel_brims() {
  linear_extrude(0.4) {
    for (a = [-1, 1]) {
      scale([a, 1]) {
        translate([barrel_width/2-11, -trunnion_length]) {
          square([7, 8]);
          translate([10, 0])
            square(8);
        }
        translate([barrel_width/2-11, -barrel_total_length-4]) {
          square([7, 8]);
          translate([10, 0])
            square(8);
        }
      }
    }
  }
}

module barrel_top_print() {
  rotate([0, 0, 45]) {
    translate([0, 0, -barrel_gap/2]) {
      rotate([90, 0, 0]) {
        intersection() {
          barrel();
          translate([-100, 0, 0])
            cube(200);
        }
      }
    }
    
    barrel_brims();
  }
}

module barrel_bottom_print() {
  rotate([0, 0, 45]) {
    translate([0, 0, barrel_height/2]) {
      rotate([90, 0, 0]) {
        intersection() {
          barrel();
          translate([-100, -200, 0])
            cube(200);
        }
      }
    }
    
    barrel_brims();
  }
}

module arm_print() {
  rotate([0, 90, 0])
    rotate([0, 0, max_arm_swing])
      arm();
}

preview_2d();
