include <common.scad>
include <barrel.scad>

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
  handle_diameter = 10;
  step_foot = 0.28;
  
  difference() {
    union() {
      translate([0, 0, step_foot])
        linear_extrude(spring_height-step_foot)
          hairspring_2d(hub_diameter, turns, thickness, 1.5)
            // Handle.
            translate([handle_diameter/2-thickness/2, 0])
              circle(d=handle_diameter);
      
      linear_extrude(0.3)
        hairspring_2d(hub_diameter, turns, thickness, 1.5, foot=step_foot)
          // Handle.
          translate([handle_diameter/2-thickness/2, 0])
            circle(d=handle_diameter-2*step_foot);
    }
    
    // Socket.
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
  // The maximum spring radius which the bracket can hold.
  max_outer_spring_radius = 48;
  max_inner_spring_radius = 40;
  end_thickness = 3;
  plate_thickness = 3;
  end_width = 25;
  base_width = 50;
  
  // Slide the base forward slightly to leave room for the fingers.
  forward = 5;
  
  height = plate_thickness*2 + spring_height + extra_loose;
  block_height = barrel_height + 14;

  // TODO:
  difference() {
    union() {
      // Main exterior.
      hull() {
        translate([0, 0, -height/2]) {
          translate([-max_outer_spring_radius - end_thickness, 0, 0])
            cube([eps, end_width, height]);
          cube([eps, end_width, height]);
          translate([max_inner_spring_radius + end_thickness, forward, 0])
            cube([eps, base_width, height]);
        }
      }
      
      // Block on the end to go over the barrel.
      hull() {
        translate([max_inner_spring_radius - eps, forward, -block_height/2])
          cube([barrel_width/2+end_thickness, base_width, block_height]);
        translate([max_inner_spring_radius - eps - 14, forward+4, -height/2])
          cube([barrel_width/2, base_width-14, height]);
      }
      
      // Reinforcing ribs on top and bottom.
      hull() {
        translate([max_inner_spring_radius + end_thickness, forward + base_width/2 - 6, -block_height/2])
          cube([eps, 4, block_height]);
        translate([-max_outer_spring_radius - end_thickness, end_width/2 - 2, -height/2-6])
          cube([eps, 4, height+12]);
      }
    }
    
    // Void for the spring.
    translate([-max_outer_spring_radius, -eps, plate_thickness - height/2])
      cube([max_outer_spring_radius + max_inner_spring_radius, base_width*2, spring_height+extra_loose]);
    
    translate([max_inner_spring_radius + end_thickness + barrel_width/2, 10, 0])
      rotate([0, 90, 0])
        barrel_cutout();
  }
}

spring_print();
