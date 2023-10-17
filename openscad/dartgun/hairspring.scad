include <common.scad>
include <barrel.scad>
include <block.scad>

nail_diameter = 3.3;

// 'start_radius' is in mm. 'slope' is in mm/turn. 't' is in turns.
function spiral_point(start_radius, slope, t) =
  (start_radius + slope*t) * [cos(t*360), sin(t*360)];
  
module spiral(start_radius, slope, turns, thickness) {
  offset(thickness/2)
    polygon([
      each [for (t = [0:0.02:turns]) spiral_point(start_radius-eps, slope, t)],
      each [for (t = [turns:-0.02:0]) spiral_point(start_radius+eps, slope, t)],
    ]);
}

module hairspring_2d(hub_diameter, turns, thickness, gap, foot=0) {
  start_radius = hub_diameter/2 - thickness/2;
  slope = thickness + gap;
  
  difference() {
    union() {
      circle(d=hub_diameter);
      spiral(start_radius, slope, turns, thickness-2*foot);
    }

    // Square off the loose end.
    rotate([0, 0, turns*360])
      translate([start_radius + slope*turns, thickness/2 + gap/2])
        square(thickness + gap, center=true);
  }
  
  // Add a handle on the end, as requested by the caller.
  rotate([0, 0, turns*360])
    translate([start_radius + slope*turns, 0])
      children();
}

socket_diameter = 7;
spring_height = 12;

module spring() {
  hub_diameter = 15;
  turns = 5;
  thickness = 3;
  gap = 2;
  handle_diameter = 10;
  step_foot = 0.28;
  
  difference() {
    union() {
      translate([0, 0, step_foot]) {
        linear_extrude(spring_height-step_foot) {
          hairspring_2d(hub_diameter, turns, thickness, gap) {
            // Handle.
            translate([handle_diameter/2-thickness/2, 0]) {
              difference() {
                circle(d=handle_diameter);
                circle(d=nail_diameter+snug);
              }
            }
          }
        }
      }
      
      linear_extrude(0.3) {
        hairspring_2d(hub_diameter, turns, thickness, gap, foot=step_foot) {
          // Handle.
          translate([handle_diameter/2-thickness/2, 0]) {
            difference() {
              circle(d=handle_diameter-2*step_foot);
              circle(d=nail_diameter+snug+2*step_foot);
            }
          }
        }
      }
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
}

module spring_print() {
  // Orient the spring so that Cura puts the seam on the handle rather than midway
  // along the outer loop.
  rotate([0, 0, 180])
    spring();
}

bracket_plate_thickness = 5;
spring_cavity_height = spring_height + 0.8;

module bracket() {
  length = 57;
  max_spring_radius = 50;
  
  body_height = spring_cavity_height + 2*bracket_plate_thickness;
  body_width = max_spring_radius + 1.5*socket_diameter;

  difference() {
    union() {
      translate([0, 0, spring_cavity_height/2])
        block(length);

      // Support under the block.
      hull() {
        translate([0, 0, spring_cavity_height/2])
          linear_extrude(eps)
            square([block_height, length], center=true);
        linear_extrude(eps)
          square([block_height, length], center=true);
        translate([0, 0, -0.6*block_height])
          linear_extrude(eps)
            square(eps, center=true);
      }
      
      // Body.
      hull() {
        linear_extrude(eps)
          square([body_height, length], center=true);
        translate([0, -length/4, -body_width])
          linear_extrude(eps)
            square([body_height, length/2], center=true);
      }
      
      // Reinforcing ribs.
      hull() {
        linear_extrude(eps)
          square([block_height, bracket_plate_thickness], center=true);
        translate([0, -bracket_plate_thickness, -body_width])
          linear_extrude(eps)
            square([body_height, bracket_plate_thickness], center=true);
      }
    }
    
    // Main spring cavity.
    translate([-spring_cavity_height/2, -50, -100])
      cube([spring_cavity_height, 100, 100]);
    
    // Steeple the top.
    steeple_side = spring_cavity_height/sqrt(2);
    translate([0, 0, 0])
      rotate([0, 45, 0])
        cube([steeple_side, 100, steeple_side], center=true);
    
    // Avoid elephant foot inside the cavity.
    chamfer_side = (spring_cavity_height+1)/sqrt(2);
    translate([0, 0, -body_width])
      rotate([0, 45, 0])
        cube([chamfer_side, 100, chamfer_side], center=true);
    
    // Socket.
    translate([0, 8-length/2, 10-body_width])
      rotate([45, 0, 0])
        cube([50, socket_diameter, socket_diameter], center=true);

    // Zip tie channels.
    channel_height = 2.2;
    channel_width = 6.5;
    for (a = [-1, 1]) {
      scale([1, a, 1]) {
        translate([0, length/2-12, spring_cavity_height/4]) {
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
  }
}

cam_major_diameter = 50;
cam_minor_diameter = 20;
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
  translate([-3, -cam_thickness/2 - cam_minor_diameter/2 + inset + 1.5, cam_thickness/2]) {
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
pin_width = socket_diameter - extra_loose;

module pin() {
  rotate([90, 0, 0]) {
    difference() {
      translate([-pin_width/2, -pin_width/2, 0])
        chamfered_cube([pin_width, pin_width, pin_length], foot);
      translate([0, 0, -eps])
        linear_extrude(pin_length+2*eps)
          octagon(nail_diameter+extra_loose);
    }
  }
}

// TODO: remove from here to end when done printing for Melody.

module heart_2d(size) {
  extra = 1.2;
  for (a = [-1, 1]) {
    hull() {
      rotate([0, 0, 45])
        square(size, center=true);
      translate(extra * [a*size/(2*sqrt(2)), size/(2*sqrt(2))])
        circle(d=size);
    }
  }
}

module heart(size, height, inset=0) {
  for (z = [0:0.2:height])
    translate([0, 0, -z])
      linear_extrude(0.2+eps)
        offset(-z-inset)
          heart_2d(size);
}

module melody_spring() {
  height = 12;
  turns = 7;
  thickness = 3;
  gap = 0.6;
  handle_diameter = 10;
  
  difference() {
    union() {
      translate([0, 0, 0.3])
        linear_extrude(height-0.3)
          hairspring_2d(handle_diameter, turns, thickness, gap)
            translate([handle_diameter/2-thickness/2, 0])
              circle(d=handle_diameter);
      
      linear_extrude(0.3)
        hairspring_2d(handle_diameter, turns, thickness, gap, foot=0.3)
          translate([handle_diameter/2-thickness/2, 0])
            circle(d=handle_diameter-2*0.3);
    }
    
    translate([0, -6, height+eps]) {
      difference() {
        heart(27, 2);
        
        translate([0, 0, -1.8])
          scale([1, 1, -1])
            heart(27, 2.2, inset=3);
      }
    }
  
    scale([1, 1, -1]) {
      translate([0, -6, 0]) {
        difference() {
          heart(27, 2);
          
          translate([0, 0, -1.8])
            scale([1, 1, -1])
              heart(27, 2.2, inset=3);
        }
      }
    }
  }
}

melody_spring();
