include <common.scad>
include <barrel2.scad>
include <post.scad>

grip_length = 53;
grip_height = 85;
grip_circle_diameter = slider_width*0.9;

// 3/8" aluminum or steel rod.
roller_cavity_diameter = 0.375 * 25.4 + loose;

// How far into the barrel does the roller intrude? One quarter of
// its diameter.
roller_intrusion = 0.375 * 25.4 / 4;
roller_x = -7;

module handle() {
  difference() {
    intersection() {
      hull() {
        for (y = (grip_length/2 - grip_circle_diameter/2) * [-1, 1]) {
          translate([0, y, 0]) {
            linear_extrude(eps)
              circle(grip_circle_diameter/2-2);
            translate([0, 0, 2])
              linear_extrude(eps)
                circle(grip_circle_diameter/2);
            translate([0, 0, grip_height])
              linear_extrude(eps)
                circle(grip_circle_diameter/2);
          }
        }
      }
        
      translate([-slider_width/2 + 4, -100, 0])
        cube([slider_width/2 - 4, 200, grip_height + grip_circle_diameter/2]);
    }
  }
}

button_width = 8;
button_cavity_width = button_width + extra_loose;

button_pivot_od = 7;
button_pivot_y = -grip_height + slider_wall + 22;

button_stop_offset = [-7, 42];
button_stop_od = 6;

button_front_height = 25;
button_ring_thickness = 8;
button_ring_od = button_pivot_od + button_ring_thickness;
button_rod_length = -button_pivot_y + slider_wall - roller_cavity_diameter;

pull_angle = 9.3;

module foregrip() {
  difference() {
    intersection() {
      union() {
        translate([0, slider_height/2, 0])
          rotate([0, 90, 90])
            slider(grip_length, slot=100, zip_channels=[6, grip_length-6], zip_orientation=false);
        
        translate([0, -grip_height, 0])
          rotate([0, -90, -90])
            handle();
      }
      
      translate([0, 0, -100])
        cube(200, center=true);
    }
    
    // Interior cavity for the button mechanism.
    translate([0, slider_wall - grip_height/2 + eps, 0])
      cube([grip_length - 12, grip_height, button_cavity_width], center=true);
        
    // Vertical guide for the roller. Slightly recessed so that the roller stays in
    // place even without the barrel above it.
    translate([roller_x, 0, -barrel_width/2 - 3])
      linear_extrude(slider_width)
        hull()
          for (y = [0, roller_intrusion])
            translate([0, slider_wall - roller_cavity_diameter/2 + y])
              circle(d=roller_cavity_diameter);
          
    // Button pivot root.
    translate([roller_x, button_pivot_y])
      translate([0, 0, -button_cavity_width/2 - 3])
        cylinder(h=button_cavity_width/2, d=button_pivot_od-3.5);
          
    // Button stop root.
    translate([roller_x, button_pivot_y] + button_stop_offset)
      translate([0, 0, -button_cavity_width/2 - 3])
        cylinder(h=button_cavity_width/2, d=button_stop_od-3.5);
          
    // Opening in front for the button.
    translate([-grip_length, -34.5, -button_cavity_width/2])
      cube([grip_length, 34, button_cavity_width]);
          
    // Rubber band post holes.
    translate([0, 0, -button_cavity_width/2 - post_hole_depth])
      linear_extrude(post_hole_depth + eps)
        for (xy = [
          [13, -2],
          [13, -12],
          [13, -22],
          [13, -32],
          [13, -42],
        ])
          translate(xy)
            square(post_hole_width, center=true);
  }
  
  // Button pivot.
  translate([roller_x, button_pivot_y]) {
    translate([0, 0, -button_cavity_width/2]) {
      difference() {
        cylinder(h=button_cavity_width/2, d=button_pivot_od);
        translate([0, 0, -eps])
          cylinder(h=button_cavity_width/2+2*eps, d=button_pivot_od-3.5);
      }
    }
  }
  
  // Button stop.
  translate([roller_x, button_pivot_y] + button_stop_offset) {
    translate([0, 0, -button_cavity_width/2]) {
      difference() {
        cylinder(h=button_cavity_width/2, d=button_stop_od);
        translate([0, 0, -eps])
          cylinder(h=button_cavity_width/2+2*eps, d=button_stop_od-3.5);
      }
    }
  }
}

module button_2d() {  
  difference() {
    union() {
      // Ring around the pivot.
      circle(d=button_ring_od);
      
      // Main rod.
      translate([0, button_rod_length/2 - 1])
        square([button_ring_od, button_rod_length - 2], center=true);
      
      // Side rod for rubber band.
      side_rod_length = 21.8;
      side_rod_width = button_ring_od*0.7;
      translate([0, -(button_ring_od - side_rod_width)/2]) {
        translate([side_rod_length/2, 0])
          square([side_rod_length, side_rod_width], center=true);
        translate([side_rod_length, 0])
          circle(d=side_rod_width);
      }
      
      // Cam surface.
      slope = 0.51;
      polygon([
        [0, 0],
        each [for (a = [7 : -0.5 : -2.5]) (button_rod_length + roller_intrusion) * [sin(a), cos(a)]],
        each [for (a = [-2.5 : -0.5 : -7.5]) (button_rod_length + roller_intrusion + slope*(a+2.5)) * [sin(a), cos(a)]],
        each [for (a = [-7.5 : -0.5 : -15]) (button_rod_length + roller_intrusion - slope*5) * [sin(a), cos(a)]],
      ]);
        
      // Front protrusion.
      intersection() {
        outer_radius = button_rod_length + 3;
        difference() {
          $fn = 100;
          
          circle(outer_radius);
          circle(outer_radius - button_front_height);
          
          // Round off the front.
          rotate([0, 0, 10])
            translate([-42, 0])
              square([20, 80]);
        }
        
        a1 = -15;
        a2 = -37;
        chamfer_a = 2;
        polygon([
          [0, 0],
          (outer_radius-1) * [sin(a1+1), cos(a1+1)],
          (outer_radius) * [sin(a1+eps), cos(a1+eps)],
          (outer_radius+10) * [sin(a1), cos(a1)],
          (outer_radius+10) * [sin(a2), cos(a2)],
        ]);
      }
    }
    
    // Hole for pivot.
    circle(d=button_pivot_od+loose);
    
    // Arc for button stop pin.
    for (a = [0 : 0.5 : pull_angle])
      rotate([0, 0, a])
        translate(button_stop_offset)
          circle(d=button_stop_od + extra_loose);
  }
}

module button() {
  translate([0, 0, -button_width/2])
    linear_extrude(button_width)
      button_2d();
}

module preview(pulled=false) {
  foregrip();
  
  color("lightblue")
    translate([roller_x, button_pivot_y])
      rotate([0, 0, pulled ? -pull_angle : 0])
        button();
  
  color("pink")
    translate([roller_x, slider_wall - roller_cavity_diameter/2 + (pulled ? 0 : roller_intrusion), -10])
      cylinder(h=10, d=roller_cavity_diameter);
}

// TODO: fill the top part of the barrel slightly, to reinforce the ridge which
// keeps the lower barrel piece against the roller.

preview(true);