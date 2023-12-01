include <common.scad>
include <barrel2.scad>
include <link.scad>
include <screw.scad>
include <spiral.scad>

nail_diameter = 3.3;
nail_loose_diameter = 3.7;

socket_diameter = 7;
spring_height = 12;
spring_hub_diameter = 15;
spring_thickness = 3;
spring_gap = 3;
spring_turns = 5;

module hairspring_2d(foot=0) {
  start_radius = spring_hub_diameter/2 - spring_thickness/2;
  slope = spring_thickness + spring_gap;
  
  difference() {
    union() {
      circle(d=spring_hub_diameter-2*foot);
      spiral(start_radius, slope, spring_turns, spring_thickness-2*foot);
    }

    // Square off the loose end.
    rotate([0, 0, spring_turns*360])
      translate([start_radius + slope*spring_turns, spring_thickness/2 + spring_gap/2])
        square(spring_thickness + spring_gap, center=true);
  }
  
  // Add a handle on the end, as requested by the caller.
  handle_id = nail_loose_diameter;
  handle_od = handle_id + 2*spring_thickness;
  
  rotate([0, 0, spring_turns*360]) {
    translate([start_radius + slope*spring_turns + handle_od/2 - spring_thickness/2, 0]) {
      difference() {
        circle(d=handle_od - 2*foot);
        circle(d=handle_id + 2*foot);
      }
    }
  }
}

// The distance between the centers of the two holes.
spring_hole_spacing =
  spring_hub_diameter/2 + spring_thickness/2 + (spring_thickness + spring_gap) * spring_turns + snug;

// Print with 20% cubic infill.
module spring() {
  handle_diameter = 10;
  step_foot = 0.28;
    
  difference() {
    union() {
      translate([0, 0, step_foot])
        linear_extrude(spring_height-step_foot)
          hairspring_2d();
      
      linear_extrude(0.3)
        hairspring_2d(foot=step_foot);
    }
    
    // Socket.
    for (a = [0, 45])
      rotate([0, 0, a])
        translate([-socket_diameter/2, -socket_diameter/2, -eps])
          flare_cube([socket_diameter, socket_diameter, spring_height+2*eps], -foot);
    
    // Marker pointing to the outer end. This allows us to gauge relaxation of the
    // spring over its useful life.
    translate([6, 0, spring_height])
      rotate([45, 0, 0])
        cube([5, 1, 1], center=true);
  }
  
  // Brim for extreme end.
  linear_extrude(0.2) {
    difference() {
      translate([spring_hole_spacing+3, -(handle_diameter-3)/2])
        square([6, handle_diameter-3]);
      hairspring_2d();
    }
  }
}

module spring_print() {
  // Orient the spring so that Cura puts the seam on the handle rather than midway
  // along the outer loop.
  rotate([0, 0, 180])
    spring();
}

// Original cams had maj=50 and min=18.2. This gave a very tight string in
// the neutral position but a disappointing muzzle velocity. Here we are
// trying some other settings:
cam_major_diameter = 45;
cam_minor_diameter = 25;
cam_thickness = 12;
cam_inset = 4;

module cam_2d() {
  intersection() {
    translate([0, 50, 0]) square(100, center=true);
    circle(d=cam_major_diameter);
  }
  intersection() {
    translate([0, -50, 0]) square(100, center=true);
    hull()
      for (a = [-1, 1])
        translate([a*(cam_major_diameter-cam_minor_diameter)/2, 0, 0])
          circle(d=cam_minor_diameter);
  }
}

module cam_slice(thickness, top_inset, bottom_inset) {
  hull() {
    linear_extrude(eps)
      offset(bottom_inset)
        cam_2d();
    translate([0, 0, thickness])
      linear_extrude(eps)
        offset(top_inset)
          cam_2d();
  }
}

// Print with 10% triangle infill.
module cam() {
  // Profile.
  bottom_flat = 0.8;
  middle_flat = 2;
  incline = (cam_thickness - 2*bottom_flat - middle_flat) / 2;
  
  // Center the whole thing on the middle of the hole.
  translate([-cam_major_diameter/2 + cam_minor_diameter/2, 0, 0]) {
    difference() {
      union() {
        cam_slice(foot, 0, -foot);
        translate([0, 0, foot])
          cam_slice(bottom_flat-foot, 0, 0);
        translate([0, 0, bottom_flat])
          cam_slice(incline, -cam_inset, 0);
        translate([0, 0, bottom_flat+incline])
          cam_slice(middle_flat, -cam_inset, -cam_inset);
        translate([0, 0, bottom_flat+incline+middle_flat])
          cam_slice(incline, 0, -cam_inset);
        translate([0, 0, bottom_flat+incline+middle_flat+incline])
          cam_slice(bottom_flat, 0, 0);
      }
      
      translate([(cam_major_diameter-cam_minor_diameter-socket_diameter)/2, -socket_diameter/2, -eps])
        flare_cube([socket_diameter, socket_diameter, cam_thickness+3*eps], -foot);
    }
    
    // Holder for end of string.
    translate([-3, -cam_thickness/2 - cam_minor_diameter/2 + cam_inset + 1.7, cam_thickness/2]) {
      difference() {
        // Exterior.
        translate(-cam_thickness/2 * [1, 1, 1])
          chamfered_cube(cam_thickness * [1, 1, 1], 0.7);
        
        // Socket for knot.
        knot_diameter = 9.5;
        translate([-3, -knot_diameter/2, -knot_diameter/2])
          chamfered_cube([cam_thickness, knot_diameter, knot_diameter], 2);
        
        // Hole for string.
        narrow_string_diameter = 4;
        translate([-cam_thickness, -16, -narrow_string_diameter/2])
          chamfered_cube([cam_thickness*2, 20, narrow_string_diameter], 1);
      }
    }
  }
}

pin_length = spring_height*4 + cam_thickness;
pin_width = socket_diameter - snug;

// Print with 40% grid infill.
module pin() {
  rotate([90, 0, 0]) {
    difference() {
      translate([-pin_width/2, -pin_width/2, 0])
        chamfered_cube([pin_width, pin_width, pin_length], foot);
      translate([0, 0, -eps])
        linear_extrude(pin_length+2*eps)
          // Make the fit extra loose, since this joint will be subjected to high speed.
          octagon(nail_loose_diameter+0.1);
    
      // Extra chamfer on ends so the printer doesn't flare the ends.
      extra_chamfer = 1.4;
      for (a = [-1, 1], b = [0, 90], c = [-1, 1]) {
        rotate([0, 0, b]) {
          scale([a, 1, c]) {
            translate([pin_width/2-extra_chamfer+eps, pin_width/2, c == 1 ? -eps : -pin_length-eps]) {
              rotate([90, 0, 0]) {
                scale([1, 2, 1]) {
                  difference() {
                    cube([extra_chamfer, extra_chamfer, pin_width]);
                    translate([0, extra_chamfer, 0])
                      cylinder(pin_width, r=extra_chamfer);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module round_cut(radius, length) {
  translate([-radius, length/2, 0]) {
    rotate([90, 0, 0]) {
      linear_extrude(length) {
        difference() {
          square(radius+1);
          circle(radius, $fn = 60);
        }
      }
    }
  }
}

bracket_length = 62;

// Include room for 4 stacked springs.
// Add 2 extra millimeters for plenty of clearance.
spring_cavity_height = spring_height*4 + cam_thickness + 2;

bracket_plate_thickness = 6;
bracket_height = spring_cavity_height + 2*bracket_plate_thickness;

pin_hole_y = -bracket_length/2 + 10;
pin_hole_z = -nail_diameter - spring_thickness;

module bracket() {
  body_width = spring_hole_spacing + 12;
  tip_length = bracket_length/2;
  
  screw_post_z = 8;
  screw_post_y = bracket_length*0.36;
    
  difference() {
    union() {
      // Slider which adapts to barrels.
      translate([0, 0, bracket_plate_thickness + slider_width/2])
        rotate([0, 90, 0])
          slider(bracket_length, 22, zip_channels=[10]);

      // Link anchors. We only need one, but if we put it on both sides then the entire
      // part is reflection symmetric.
      //
      // They protrude forward somewhat to give better leverage in the collapsed position.
      anchor_protrusion = 10;
      for (a = [-1, 1]) {
        scale([a, 1, 1]) {
          translate([slider_height/2, bracket_length/2 - main_diameter/2 + anchor_protrusion, bracket_plate_thickness]) {
            translate([0, 0, slider_width/2 - link_anchor_thickness])
              scale([1, -1, 1])
                link_anchor(spread=1.3);
              
            // Fillet the protrusion to the front of the slider.
            hull() {
              translate([0, -main_diameter/2, 0])
                cube([eps, main_diameter, slider_width/2]);
              translate([-slider_wall+1, -main_diameter/2, 0])
                cube([eps, eps, slider_width/2]);
            }
          }
        }
      }
      
      // Body.
      hull() {
        // Bevel off the sharp corners.
        translate([0, 0, bracket_plate_thickness+2])
          linear_extrude(1)
            square([bracket_height-2, bracket_length-2], center=true);
        
        translate([0, 0, bracket_plate_thickness])
          linear_extrude(2)
            square([bracket_height, bracket_length], center=true);
        translate([0, tip_length/2-bracket_length/2, -body_width])
          linear_extrude(eps)
            square([bracket_height, tip_length], center=true);
      }
      
      // Screw posts.
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([slider_height/2, screw_post_y, -screw_post_z])
            linear_extrude(50)
              octagon(washer_od+0.7);
    }
    
    // Cut off the top half of the slider and link anchor.
    translate([0, 0, 50 + bracket_plate_thickness + slider_width/2])
      cube(100, center=true);
    
    // Prevent elephant foot from intruding into the spring cavity.
    for (x = spring_cavity_height/2 * [-1, 1])
      translate([x, -bracket_length/2, -50])
        rotate([0, 0, 45])
          cube([1, 1, 100], center=true);
    
    // Avoid the spring sticking against the ends.
    for (a = [-1, 1])
      translate([a*spring_cavity_height/2, 0, -body_width])
        rotate([0, 45, 0])
          cube([1, 100, 1], center=true);
      
    // Pin holes.
    for (z = [pin_hole_z, pin_hole_z-spring_hole_spacing])
      translate([0, pin_hole_y, z])
        rotate([0, 90, 0])
          translate([0, 0, -bracket_height/2-2])
            linear_extrude(bracket_height+4)
              octagon(nail_loose_diameter);
    
    // Slits to cause more walls to be printed near the pin holes, reinforcing
    // them.
    slit_width = 0.01;
    for (x = (spring_cavity_height/2 + bracket_plate_thickness/2) * [-1, 1], z = [0, -spring_hole_spacing])
      translate([x, pin_hole_y, pin_hole_z + z])
        cube([slit_width, 2*nail_loose_diameter, 2*nail_loose_diameter], center=true);

    // Main spring cavity.
    translate([-spring_cavity_height/2, pin_hole_y-100, -100])
      cube([spring_cavity_height, 100, 100]);
    translate([-spring_cavity_height/2, pin_hole_y, pin_hole_z - spring_hole_spacing])
      rotate([0, 90, 0])
        cylinder(h=spring_cavity_height, r = spring_hole_spacing - pin_hole_z, $fa=5);
    
    // Screw holes in front.
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        translate([slider_height/2, screw_post_y, 0]) {
          // Countersink for washer assembly.
          translate([0, 0, -screw_post_z - 8])
            linear_extrude(8)
              octagon(washer_od+0.7);
          
          // Main shaft.
          translate([0, 0, -50])
            linear_extrude(100)
              octagon(screw_hole_id);
          
          // Bolt head shaft.
          translate([0, 0, -screw_post_z - 20])
            linear_extrude(20)
              octagon(screw_head_od + 0.5);
        }
      }
    }
    
    // Slightly flare the edges of the slider, so there isn't a motion artifact which
    // intrudes into the barrel cavity.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([-barrel_height/2, 0, bracket_plate_thickness + slider_width/2 - 5])
          round_cut(20, bracket_length + 2*eps);
    
    // Cavity which holds the retention plate nut.
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        translate([
          spring_cavity_height/2 + bracket_plate_thickness + eps,
          pin_hole_y,
          pin_hole_z - spring_hole_spacing/2
        ]) {
          rotate([90, 90, -90]) {
            nut_cavity();
            linear_extrude(10)
              octagon(screw_hole_id);
          }
        }
      }
    }
  }

  // Block to keep springs separated.
  translate([-cam_thickness/2, -bracket_length/2, -0.5-spring_thickness])
    chamfered_cube([cam_thickness, 4*spring_thickness, spring_thickness+2], 0.4);

  // Clips for removable retention plates.
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([
        spring_cavity_height/2 + bracket_plate_thickness + retention_plate_thickness,
        pin_hole_y + retention_plate_width/2,
        pin_hole_z - spring_hole_spacing - retention_plate_clip_length/2
      ])
        rotate([90, 0, -90])
          retention_plate_clips();
          
  // Print aids.
  translate([0, -bracket_length/2, 0]) {
    rotate([-90, 0, 0]) {
      linear_extrude(0.4) {
        for (a = [-1, 1]) {
          scale([a, 1, 1]) {
            translate([slider_height/2 - slider_wall/2, -5 -bracket_plate_thickness - slider_width/2])
              square(10, center=true);
            translate([spring_cavity_height/2 + bracket_plate_thickness/2, 5 + body_width])
              square(10, center=true);
            translate([5 + bracket_height/2, -5])
              square(10, center=true);
          }
        }
      }
    }
  }
}

retention_plate_thickness = 1.2;
retention_plate_width = washer_od;
retention_plate_clip_length = 9;
retention_plate_length = spring_hole_spacing + retention_plate_clip_length;

// Plate which covers the ends of the pins.
module retention_plate() {
  dims = [retention_plate_width, retention_plate_length, 2*retention_plate_thickness];

  difference() {
    // Chamfer only the bottom.
    intersection() {
      chamfered_cube(dims, 0.4);
      translate([0, 0, -retention_plate_thickness])
        cube(dims);
    }
    
    translate(dims/2 - [0, 0, 5])
      linear_extrude(10)
        octagon(screw_hole_id);
  }
}

module retention_plate_clips() {
  clearance = extra_loose;
  height = retention_plate_thickness * 2 + clearance;

  difference() {
    translate([-height-1, 0, -height + retention_plate_thickness]) {
      intersection() {
        translate([0, -retention_plate_length/2, 0])
          chamfered_cube([retention_plate_width + 2*height + 2, retention_plate_length*2, 2*height], height);
        for (y = [0, retention_plate_length - retention_plate_clip_length])
          translate([0, y, -height])
            cube([retention_plate_width + 2*height + 2, retention_plate_clip_length, 2*height]);
      }      
    }
    
    // Cavity for the plate.
    translate([-clearance/2, -eps, -clearance + eps])
      cube([
        retention_plate_width + clearance,
        retention_plate_length + 2*eps,
        retention_plate_thickness + clearance
      ]);
    
    // Pin holes.
    for (y = [0, retention_plate_length - retention_plate_clip_length])
      translate([retention_plate_width/2, retention_plate_clip_length/2 + y, -5])
        linear_extrude(10)
          octagon(nail_loose_diameter);
  }
}

module preview() {
  bracket();
  
  for (x = [-cam_thickness/2, spring_height+cam_thickness/2])
    translate([x, pin_hole_y, pin_hole_z-spring_hole_spacing])
      rotate([0, -90, 0])
        scale([1, -1, 1])
          spring();
}

// Print 2 cams at once.
module cam_2_print() {
  for (a = [0, 180])
    rotate([0, 0, a])
      translate([6, 16.5, 0])
        cam();
}

// Print with 40% cubic subdivision infill. 2mm layers.
module bracket_print() {
  rotate([90, 0, 0])
    bracket();
}

bracket_print();
