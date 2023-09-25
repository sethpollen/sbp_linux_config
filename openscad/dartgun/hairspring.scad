include <common.scad>
include <barrel.scad>
include <block.scad>

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
tunnel_id = string_diameter + 0.9;

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
      translate([0, 0, step_foot])
        linear_extrude(spring_height-step_foot)
          hairspring_2d(hub_diameter, turns, thickness, gap)
            // Handle.
            translate([handle_diameter/2-thickness/2, 0])
              circle(d=handle_diameter);
      
      linear_extrude(0.3)
        hairspring_2d(hub_diameter, turns, thickness, gap, foot=step_foot)
          // Handle.
          translate([handle_diameter/2-thickness/2, 0])
            circle(d=handle_diameter-2*step_foot);
    }
    
    // Socket.
    for (a = [0, 45])
      rotate([0, 0, a])
      translate([-socket_diameter/2, -socket_diameter/2, -eps])
        flare_cube([socket_diameter, socket_diameter, spring_height+2*eps], -foot);
    
    // String tunnel.
    translate([32, 0, spring_height/2])
      rotate([90, 0, 20])
        translate([0, 0, -handle_diameter])
          linear_extrude(2*handle_diameter)
            octagon(tunnel_id);
  }
}

module spring_print() {
  // Orient the spring so that Cura puts the seam on the handle rather than midway
  // along the outer loop.
  rotate([0, 0, 180])
    spring();
}

module bracket() {
  length = 57;
  max_spring_radius = 50;
  plate_thickness = 5;
  spring_cavity_height = spring_height + 0.8;
  
  body_height = spring_cavity_height + 2*plate_thickness;
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
          square([block_height, plate_thickness], center=true);
        translate([0, -plate_thickness, -body_width])
          linear_extrude(eps)
            square([body_height, plate_thickness], center=true);
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

bracket();
