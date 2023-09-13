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

module hairspring(hub_diameter, turns, thickness) {
  start_radius = hub_diameter/2 - thickness/2;
  gap = 0.6;
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

lug_diameter = 8;

linear_extrude(10) {
  start_radius = lug_diameter * 1.7;
  turns = 5;
  thickness = 3;
  handle_radius = 5;

  // Spring with lug socket.
  difference() {
    hairspring(start_radius, turns, thickness) {
      // Handle.
      translate([handle_radius-thickness/2, 0])
        circle(handle_radius);
    }
    circle(d=lug_diameter + loose, $fn = 3);
  }
}