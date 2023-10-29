include <common.scad>
include <barrel.scad>
include <block.scad>

trigger_width = 8;
trigger_cavity_width = trigger_width + extra_loose;
grip_length = 52;

module receiver() {
  block1_length = 58;
  trigger_cavity_length = 25;
  block2_length = 75;
  trigger_cavity_wall = 3;
  trigger_pivot_diameter = 6;

  difference() {
    union() {
      difference() {
        block(block1_length);
        for (y = [5, 15, 25])
          translate([0, y])
            zip_tie_aids();
      }
      translate([-block_height/2, block1_length/2, 0])
        cube([block_height, block2_length, block_width]);
    }
    
    // String gap.
    cube([barrel_gap, block1_length+eps, 100], center=true);
    
    // Trigger cavity.
    translate([0, block1_length/2-eps, block_width-trigger_cavity_width/2])
      cube([block_height, trigger_cavity_length, block_width]);
    translate([-(block_height-trigger_cavity_wall*2)/2, block1_length/2-eps, block_width-trigger_cavity_width/2])
        cube([block_height-trigger_cavity_wall*2, block2_length-trigger_cavity_wall, block_width]);
  }

  pin_extension = 6;
  pin_height = block_width + trigger_cavity_width/2 + pin_extension;
  
  // Trigger pivot.
  translate([0, block1_length/2 + trigger_cavity_length/2]) {
    difference() {
      $fn = 50;
      cylinder(pin_height, d=trigger_pivot_diameter);
      // Force more walls inside the pivot for added strength.
      cylinder(pin_height + eps, d=trigger_pivot_diameter-3);
    }
  }
  
  // Trigger spring anchors.
  for (y = [15, 40])
    translate([block_height/2 - trigger_cavity_wall - 5, block1_length/2 + trigger_cavity_length + y, 0])
      cylinder(pin_height, d=4.5);
  
  translate([block_height/2, block1_length/2 + trigger_cavity_length + grip_length/2, block_width])
    rotate([0, -90, 180])
      grip();
}

// Only the right-hand half of the grip.
module grip() {
  height = 85;
  circle_diameter = block_width*2.4;
  
  intersection() {
    translate([-block_width, -100, 0])
      cube([block_width, 200, height]);
    
    hull()
      for (y = (grip_length/2 - circle_diameter/2) * [-1, 1], z = [0, height])
        translate([0, y-z*0.25, z])
          linear_extrude(eps)
            circle(d=circle_diameter);
  }
}

receiver();

// TODO: needs work
module trigger_2d() {
  rod_height = 6;
  rod_length = 30;
  gap_plus = barrel_gap+1;
  
  hull()
    for (xy = [
      gap_plus*[0.25, 0.75],
      gap_plus*[2, -0.25],
      [gap_plus*2, -rod_height+gap_plus*0.25],
      [gap_plus*0.25, -rod_height+gap_plus*0.25],
    ])
      translate(xy)
        circle(gap_plus*0.25);
  
  translate([-rod_length, -rod_height])
    square([rod_length+gap_plus*0.25, rod_height]);
}

