include <common.scad>
include <barrel.scad>
include <block.scad>

nail_diameter = 3.3;
nail_loose_diameter = 3.7;
nail_snug_diameter = 3.6;

// 'start_radius' is in mm. 'slope' is in mm/turn. 't' is in turns.
function spiral_point(start_radius, slope, t) =
  (start_radius + slope*t) * [cos(t*360), sin(t*360)];
  
module spiral(start_radius, slope, turns, thickness) {
  offset(thickness/2)
    polygon([
      each [for (t = [0:0.01:turns]) spiral_point(start_radius-eps, slope, t)],
      each [for (t = [turns:-0.01:0]) spiral_point(start_radius+eps, slope, t)],
    ]);
}

socket_diameter = 7;
spring_height = 12;
spring_hub_diameter = 15;
spring_thickness = 3;
spring_gap = 3;
spring_turns = 5;

spring_handle_id = nail_loose_diameter;
spring_handle_od = spring_handle_id + 2*spring_thickness;

module hairspring_2d(foot=0) {
  start_radius = spring_hub_diameter/2 - spring_thickness/2;
  slope = spring_thickness + spring_gap;
  
  difference() {
    union() {
      circle(d=spring_hub_diameter);
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

cam_major_diameter = 50;
cam_minor_diameter = 18.2;
cam_thickness = 12;

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
  
  inset = 4;
  
  difference() {
    union() {
      cam_slice(foot, 0, -foot);
      translate([0, 0, foot])
        cam_slice(bottom_flat-foot, 0, 0);
      translate([0, 0, bottom_flat])
        cam_slice(incline, -inset, 0);
      translate([0, 0, bottom_flat+incline])
        cam_slice(middle_flat, -inset, -inset);
      translate([0, 0, bottom_flat+incline+middle_flat])
        cam_slice(incline, 0, -inset);
      translate([0, 0, bottom_flat+incline+middle_flat+incline])
        cam_slice(bottom_flat, 0, 0);
    }
    
    translate([(cam_major_diameter-cam_minor_diameter-socket_diameter)/2, -socket_diameter/2, -eps])
      flare_cube([socket_diameter, socket_diameter, cam_thickness+3*eps], -foot);
  }
  
  // Holder for end of string.
  translate([-3, -cam_thickness/2 - cam_minor_diameter/2 + inset + 1.7, cam_thickness/2]) {
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

pin_length = spring_height*2 + cam_thickness;
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

bracket_plate_thickness = 5;
bracket_length = 59;
spring_cavity_height = spring_height*2 + cam_thickness + 2;

pin_hole_y = -bracket_length/2 + 5;
pin_hole_z = -nail_diameter - spring_thickness;

module bracket() {
  body_width = spring_hole_spacing + 12;

  // Needs to be long enough to support the part during printing.
  tip_length = bracket_length/2;
  
  rib_thickness = 6;
  rib_height = 8;
    
  difference() {
    union() {
      // Block which adapts to rail.
      translate([0, 0, 2])
        block(bracket_length);
            
      // Body.
      hull() {
        translate([0, 0, 2])
          linear_extrude(eps)
            square([block_height, bracket_length], center=true);
        translate([0, tip_length/2-bracket_length/2, -body_width])
          linear_extrude(eps)
            square([block_height, tip_length], center=true);
      }
      
      // Reinforcing rib, to keep everything aligned during printing.
      translate([0, -15, 0]) {
        hull() {
          translate([0, 0, 6])
            linear_extrude(eps)
              square([block_height, rib_thickness], center=true);
          translate([0, 0, -10])
            linear_extrude(eps)
              square([block_height+2*rib_height, rib_thickness], center=true);
          translate([0, 0, -body_width])
            linear_extrude(eps)
              square([block_height+2*rib_height, rib_thickness], center=true);
        }
      }
    }
    
    // Pin holes.
    for (z = [pin_hole_z, pin_hole_z-spring_hole_spacing])
      translate([0, pin_hole_y, z])
        rotate([0, 90, 0])
          translate([0, 0, -block_height/2-2])
            linear_extrude(block_height+4)
              octagon(nail_loose_diameter);
        
    // Main spring cavity. It is composed of two blocks to leave a bridge between
    // the plates in front.
    translate([-spring_cavity_height/2, -50, -100])
      cube([spring_cavity_height, 64, 100]);
    translate([-spring_cavity_height/2, -50, -122])
      cube([spring_cavity_height, 100, 100]);
        
    // Avoid elephant foot inside the cavity.
    chamfer_side = (spring_cavity_height+2)/sqrt(2);
    translate([0, 0, -body_width])
      rotate([0, 45, 0])
        cube([chamfer_side, 100, chamfer_side], center=true);

    // Zip tie channels.
    channel_height = 2.2;
    channel_width = 6.5;
    for (y = [bracket_length/2-11, 4-bracket_length/2]) {
      translate([0, y, 2]) {
        translate([-50, 0, 0])
          cube([100, channel_width, channel_height]);
        for (b = [-1, 1])
          scale([b, 1, 1])
            translate([block_height/2 - channel_height, 0, channel_height])
              rotate([0, 45, 0])
                cube(channel_width);
      }
    }
  }
  
  // Block to keep springs separated.
  translate([-cam_thickness/2, -bracket_length/2, -0.5-spring_thickness])
    chamfered_cube([cam_thickness, 4*spring_thickness, spring_thickness+2], 0.4);
  
  // Nail paddles next to pin holes.
  translate([block_height/2-eps, pin_hole_y, -body_width/2-1])
    rotate([90, 0, 90])
      nail_paddles(body_width-2);
}

// Flexible paddles which press against the tip of the nail and keep it in place.
module nail_paddles(width) {
  thickness = 1.1;
  height = 16 + thickness;
  
  // Inset (on each side) to grip the nail.
  inset = 0.35;
  
  difference() {
    translate([0, 0, height/2])
      cube([nail_loose_diameter+thickness*2, width, height], center=true);
    translate([0, 0, (height-thickness)/2-eps])
      cube([nail_loose_diameter, width+1, height-thickness], center=true);
  }
  
  translate([0, 0, (height-thickness)/2]) {
    difference() {
      cube([nail_loose_diameter, width, 2], center=true);
      cube([nail_loose_diameter-inset*2, width+1, 3], center=true);
    }
  }
}

module preview() {
  bracket();
  for (x = [-cam_thickness/2, spring_height+cam_thickness/2])
    translate([x, pin_hole_y, pin_hole_z-spring_hole_spacing])
      rotate([0, -90, 0])
        spring();
}

// Print 2 cams at once.
module cam_2_print() {
  for (a = [0, 180])
    rotate([0, 0, a])
      translate([-8, 13, 0])
        cam();
}

preview();