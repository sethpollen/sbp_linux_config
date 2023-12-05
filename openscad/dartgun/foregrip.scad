include <common.scad>
include <barrel2.scad>

grip_length = 53;
grip_height = 85;
grip_circle_diameter = slider_width*0.9;

// 3/8" aluminum or steel rod.
roller_cavity_diameter = 0.375 * 25.4 + loose;

// How far into the barrel does the roller intrude? One quarter of
// its diameter.
roller_intrusion = 0.375 * 25.4 / 4;

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
button_pivot_offset = [
  -grip_length/2 + 16,
  -grip_height + slider_wall + 12
];
button_front_height = 22;

module foregrip() {
  difference() {
    intersection() {
      union() {
        translate([0, slider_height/2, 0])
          rotate([0, 90, 90])
            slider(grip_length, slot=100, zip_channels=[grip_length*0.75], zip_orientation=false);
        
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
    
    // Cut out for the button front to protrude.
    translate([-grip_length/2, -button_front_height/2 + eps, 0])
      cube([grip_length, button_front_height, button_cavity_width], center=true);
    
    // Vertical guide for the roller. Slightly recessed so that the roller stays in
    // place even without the barrel above it.
    translate([0, 0, -barrel_width/2 - 2])
      linear_extrude(slider_width)
        hull()
          for (y = [0, roller_intrusion])
            translate([0, slider_wall - roller_cavity_diameter/2 + y])
              circle(d=roller_cavity_diameter);
          
    // Button pivot root.
    translate(button_pivot_offset)
      translate([0, 0, -button_cavity_width/2 - 3])
        cylinder(h=button_cavity_width/2, d=button_pivot_od-3.5);
  }
  
  // Button pivot.
  translate(button_pivot_offset) {
    translate([0, 0, -button_cavity_width/2]) {
      difference() {
        cylinder(h=button_cavity_width/2, d=button_pivot_od);
        translate([0, 0, -eps])
          cylinder(h=button_cavity_width/2+2*eps, d=button_pivot_od-3.5);
      }
    }
  }
}

module button_2d() {
  translate(button_pivot_offset) {
    difference() {
      circle(d=button_pivot_od+8);
      circle(d=button_pivot_od+loose);
    }
  }
}

module button() {
  translate([0, 0, -button_width/2])
    linear_extrude(button_width)
      button_2d();
}

foregrip();
button();

////////////////////////////////////////////////////////////////
// TODO: revisit the rest of this.

// 3/8" aluminum rod.
rod = 9.8;

length = 40;
block_height = 8;

module rod_2d() {
  circle(d=rod);
}

module rail_2d() {
  difference() {
    translate([-length/2, rod/4])
      square([length, block_height]);
    circle(d=rod + loose);
  }
}

shelf_x = 2;
ramp_x = 4;
ramp_y = rod / 4;

module ramp_2d() {
  translate([0, -rod/2 - block_height - loose/2]) {
    translate([-shelf_x, 0])
      square([length / 2 + shelf_x, block_height]);
    hull() {
      translate([-shelf_x, 0])
        square([eps, block_height]);
      translate([-shelf_x - ramp_x, 0])
        square([eps, block_height - ramp_y]);
    }
    translate([-length/2, 0])
      square([length/2 - shelf_x - ramp_x, block_height - ramp_y]);
  }
}

module track_2d(hole=true, wall=4) {
  rail_width = 5;
  
  translate([0, -rod/8]) {
    difference() {
      square([rod + 2*rail_width, block_height*2 + rod - ramp_y + rail_width], center=true);
    
      if (hole)
        square([rod + loose, block_height*2 + rod - ramp_y + rail_width - wall], center=true);
    }
  }
}

function sum(list, start, limit) =
  start == limit
  ? 0
  : list[start] + sum(list, start + 1, limit);

module stack(z) {
  for (i = [0 : $children-1])
    translate([0, 0, sum(z, 0, i)])
      linear_extrude(z[i] + eps)
        children(i);
}

sliding_height = 4;

module housing() {
  stack([2, 3, sliding_height + 0.4, 1, 2]) {
    track_2d(false);
    
    track_2d(true);
    
    difference() {
      track_2d(true);
      offset(loose/2) {
        rail_2d();
        ramp_2d();
      }
    }
    
    track_2d(true);
    track_2d(true, 8);
  }
}

module extrude_foot(height) {
  linear_extrude(0.2)
    offset(-0.2)
      children();
  translate([0, 0, 0.2])
    linear_extrude(height - 0.2)
      children();
}

module print() {
  housing();

  translate([17, 0])
    extrude_foot(8 + sliding_height)
      rod_2d();

  translate([0, 28])
    extrude_foot(sliding_height)
      ramp_2d();

  translate([0, -28])
    extrude_foot(sliding_height)
      rail_2d();
}