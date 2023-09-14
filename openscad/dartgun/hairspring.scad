include <common.scad>
include <../extrude_and_chamfer.scad>

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

module hairspring_2d(hub_diameter, turns, thickness, gap) {
  start_radius = hub_diameter/2 - thickness/2;
  slope = thickness + gap;
  
  difference() {
    union() {
      circle(d=hub_diameter);
      spiral(start_radius, slope, turns, thickness);
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

spline_diameter = 7;
tunnel_id = string_diameter + 0.9;

module spring() {
  height = 12;
  hub_diameter = 15;
  turns = 5;
  thickness = 3;
  handle_diameter = 10;
  
  difference() {
    linear_extrude(height) {

      hairspring_2d(hub_diameter, turns, thickness, 1.5) {
        // Handle.
        translate([handle_diameter/2-thickness/2, 0])
          circle(d=handle_diameter);
      }
    }
    
    // Socket.
    socket_diameter = spline_diameter + snug;
    translate([-socket_diameter/2, -socket_diameter/2, -eps])
      flare_cube([socket_diameter, socket_diameter, height+2*eps], -foot);
    
    // String tunnel.
    translate([32, 0, height/2])
      rotate([90, 0, 20])
        translate([0, 0, -handle_diameter])
          linear_extrude(2*handle_diameter)
            octagon(tunnel_id);
  }
}

spring();