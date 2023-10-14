include <common.scad>
include <barrel.scad>
include <block.scad>
include <bolt.scad>

catch_gap_height = catch_height + extra_loose;
receiver_housing_length = 43.2;

trigger_pivot_offset = 10.7;
trigger_pivot_diameter = 6;

$fa = 5;

module receiver() {
  difference() {
    union() {
      translate([0, -13, 0])
        block(26);

      // Receiver housing, which holds the trigger and catch.
      translate([-block_height/2, 0, 0])
        cube([block_height, receiver_housing_length, block_width]);
    }
    
    // Slot for the catch.
    translate([-catch_gap_height/2, receiver_housing_length-52-eps, block_width-barrel_width/2 - 1 + eps])
      cube([catch_gap_height, 40+2*eps, barrel_width/2]);
    
    // Space for the hook on the back of the bolt.
    translate([-(main_bore+1)/2, -7, block_width-4+eps])
      cube([main_bore+1, receiver_housing_length+2*eps, 4]);
    
    // Pit for the bar on the back of the catch.
    pit_x = catch_height + snug;
    pit_y = catch_block_length + snug;
    pit_z = catch_block_width/2 + tight;
    translate([-pit_x/2, 35-pit_y/2, block_width-pit_z+eps])
      cube([pit_x, pit_y, pit_z]);
    
    // Cavity for trigger to move through.
    translate([-block_height/2-eps, receiver_housing_length-40.7, block_width - (hook_width+loose)/2])
      cube([block_height+2*eps, 24, hook_width+loose]);
    
    for (y = [-12, 35])
      translate([0, y, 0])
        zip_tie_aids();
  }
  
  // Trigger pivot lug.
  translate([-block_height/2, trigger_pivot_offset, 6])
    cylinder(5, 0, trigger_pivot_diameter/2);
  translate([-block_height/2, trigger_pivot_offset, 11])
    cylinder(block_width-11, d=trigger_pivot_diameter);
}

module trigger() {
  difference() {
    union() {
      linear_extrude(80)
        wedge_2d();
      
      hull() {
        translate([0, catch_link_length/2, 80]) {
          rotate([90, 0, 90])
            translate([0, 0, -hook_width/2])
              cylinder(hook_width, r=wedge_block_length+catch_link_length/2);
        
          // Add fillets underneath to aid in printing.
          translate([0, catch_link_length/2-1, -12])
            cube(eps, center=true);
        }
      }
    }
    
    translate([0, catch_link_length/2, 80])
      rotate([90, 0, 90])
        translate([0, 0, -hook_width/2-eps])
          cylinder(hook_width+2*eps, d=trigger_pivot_diameter+loose);
  }
}

module catch_preview() {
  translate([0, receiver_housing_length-35.5, block_width]) {
    rotate([90, 0, -90])
      translate([0, 0, -catch_height/2])
        catch();
  
    translate([80-block_height, 0, 0])
      rotate([180, -90, 180])
        translate([0, 0, -block_height/2])
          trigger();
  }
}

receiver();
