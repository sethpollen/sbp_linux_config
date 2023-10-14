include <common.scad>
include <barrel.scad>
include <block.scad>
include <bolt.scad>

// TODO:

catch_gap_height = catch_height + extra_loose;

module receiver() {  
  housing_length = 42;
  
  difference() {
    union() {
      translate([0, -13, 0])
        block(26);

      translate([-block_height/2, 0, 0])
        cube([block_height, housing_length, block_width]);
    }
    
    // Slot for the catch.
    translate([-catch_gap_height/2, -10-eps, block_width-barrel_width/2 - 1 + eps])
      cube([catch_gap_height, housing_length+2*eps, barrel_width/2]);
    
    // Space for the hook on the back of the bolt.
    translate([-(main_bore+1)/2, -7, block_width-4+eps])
      cube([main_bore+1, housing_length+2*eps, 4]);
    
    // Pit for the bar on the back of the catch.
    pit_x = catch_height + snug;
    pit_y = catch_block_length + snug;
    pit_z = catch_block_width/2 + tight;
    translate([-pit_x/2, 36-pit_y/2, block_width-pit_z+eps])
      cube([pit_x, pit_y, pit_z]);
  }
}

receiver();
