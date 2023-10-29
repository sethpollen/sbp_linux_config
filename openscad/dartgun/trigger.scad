include <common.scad>
include <barrel.scad>
include <block.scad>

trigger_width = 8;
trigger_cavity_width = trigger_width + extra_loose;
grip_length = 52;
grip_height = 85;

receiver_block1_length = 58;
receiver_block2_length = 75;
trigger_cavity_length = 25;
trigger_cavity_wall = 3;
trigger_pivot_diameter = 6;

spring_anchor_diameter = 4.5;

module receiver_pins_2d() {
  // Trigger pivot.
  translate([0, receiver_block1_length/2 + trigger_cavity_length/2]) {
    difference() {
      $fn = 50;
      circle(d=trigger_pivot_diameter);
      // Force more walls inside the pivot for added strength.
      circle(d=trigger_pivot_diameter-3);
    }
  }
  
  // Trigger spring anchors.
  for (y = [15, 40])
    translate([block_height/2 - trigger_cavity_wall - 5, receiver_block1_length/2 + trigger_cavity_length + y])
      circle(d=spring_anchor_diameter);
}

module receiver(pin) {
  pin_extension = 6;
  pin_height = block_width + trigger_cavity_width/2 + pin_extension;

  difference() {
    union() {
      difference() {
        block(receiver_block1_length);
        for (y = [5, 15, 25])
          translate([0, y])
            zip_tie_aids();
      }
      translate([-block_height/2, receiver_block1_length/2, 0])
        cube([block_height, receiver_block2_length, block_width]);
    }
    
    // String gap.
    cube([barrel_gap, receiver_block1_length+eps, 100], center=true);
    
    // Trigger cavity.
    translate([0, receiver_block1_length/2-eps, block_width-trigger_cavity_width/2])
      cube([block_height, trigger_cavity_length, block_width]);
    translate([-(block_height-trigger_cavity_wall*2)/2, receiver_block1_length/2-eps, block_width-trigger_cavity_width/2])
        cube([block_height-trigger_cavity_wall*2, receiver_block2_length-trigger_cavity_wall, block_width]);
    
    if (!pin)
      translate([0, 0, block_width - trigger_cavity_width/2 - pin_extension])
        linear_extrude(pin_height)
          offset(0.2)
            receiver_pins_2d();
  }
  
  if (pin)
    linear_extrude(pin_height)
      receiver_pins_2d();
    
  translate([block_height/2, receiver_block1_length/2 + trigger_cavity_length + grip_length/2, block_width])
    rotate([0, -90, 180])
      grip();
  
  // Brims.
  linear_extrude(0.2) {
    brim_offset = 0.05;
    brim_width = 4;
    
    for (y = [
      -brim_width - receiver_block1_length/2 - brim_offset,
      receiver_block1_length/2 + receiver_block2_length + brim_offset
    ])
      translate([-block_height/2, y])
        square([block_height, brim_width]);
    translate([block_height/2 + grip_height + brim_offset, 75])
      square([brim_width, grip_length]);
  }
}

// Only the right-hand half of the grip.
module grip() {
  circle_diameter = block_width*2.4;
  
  intersection() {
    translate([-block_width, -100, 0])
      cube([block_width, 200, grip_height]);
    
    hull()
      for (y = (grip_length/2 - circle_diameter/2) * [-1, 1], z = [0, grip_height])
        translate([0, y-z*0.25, z])
          linear_extrude(eps)
            circle(d=circle_diameter);
  }
}

module male_receiver() {
  receiver(true);
}

module female_receiver() {
  scale([-1, 1, 1])
    receiver(false);
}

module print_receiver() {
  male_receiver();
  translate([25, 150])
    rotate([0, 0, 90])
      female_receiver();
}

module trigger_2d() {  
  // Pivot.
  difference() {
    $fn = 40;
    square(trigger_pivot_diameter + 8, center=true);
    circle(d=trigger_pivot_diameter + extra_loose);
  }
  
  // Main rod.
  rod_length = 30;
  hull() {
    translate([barrel_gap/2, -rod_length])
      square([5, rod_length]);
    translate([barrel_gap/2, -rod_length-8])
      square(eps);
  }
  
  // Trigger.
  trigger_length = 45;
  rotate([0, 0, -10]) {
    translate([4, -2.5])
      square([trigger_length, 5]);
    translate([trigger_length+4, 0])
      circle(d=5);
  }
  
  // String catch.
  catch_round = 3;
  hull() {
    translate([barrel_gap/2, -rod_length-10+catch_round/2])
      circle(d=catch_round);
    translate([-barrel_gap/2+catch_round/2, -rod_length])
      circle(d=catch_round);
    translate([barrel_gap/2, -rod_length])
      circle(d=catch_round);
  }
}

module trigger() {
  linear_extrude(0.2)
    offset(-0.2)
      trigger_2d();
  translate([0, 0, 0.2])
    linear_extrude(trigger_width-0.2)
      trigger_2d();

  // Spring arm.
  spring_arm_length = 13;
  rotate([0, 0, 35]) {
    translate([-2, 4])
      cube([4, spring_arm_length, trigger_width/2-0.5]);
    translate([0, 4+spring_arm_length])
      cylinder(h=trigger_width, d=spring_anchor_diameter);
  }
}

module preview() {
  male_receiver();
  translate([0, receiver_block1_length/2 + trigger_cavity_length/2, block_width - trigger_width/2])
    rotate([0, 0, 17])
      trigger();
}

trigger();