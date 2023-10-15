include <common.scad>
include <barrel.scad>
include <block.scad>
include <bolt.scad>

catch_gap_height = catch_height + extra_loose + 0.1;
receiver_housing_length = 56.4;

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
    translate([-catch_gap_height/2, -8.8, block_width-barrel_width/2 - 1 + eps])
      cube([catch_gap_height, receiver_housing_length-5.2+2*eps, barrel_width/2]);
    
    // Space for the hook on the back of the bolt.
    translate([-(main_bore+1)/2, -eps, block_width-3.5+eps])
      cube([main_bore+1, 7, 3.5]);
    
    // Room for the catch between its main cavity and the pit.
    translate([0, receiver_housing_length-13, block_width])
      cube([catch_gap_height, 10, catch_spring_thickness*2 + 3], center=true);
    
    // Pit for the bar on the back of the catch.
    pit_x = catch_height + snug;
    pit_y = catch_block_length + snug;
    pit_z = catch_block_width/2 + tight;
    translate([-pit_x/2, receiver_housing_length-8.2-pit_y/2, block_width-pit_z+eps])
      cube([pit_x, pit_y, pit_z]);
    
    // Cavity for trigger to move through.
    translate([-block_height/2-eps, 2.5, block_width - hook_width/2])
      cube([block_height+2*eps, receiver_housing_length-19.2, hook_width]);
    
    translate([0, -12, 0])
      zip_tie_aids();
  }
    
  // Trigger pivot lug.
  translate([-block_height/2, trigger_pivot_offset, 6])
    cylinder(5, 0, trigger_pivot_diameter/2);
  translate([-block_height/2, trigger_pivot_offset, 11])
    cylinder(block_width-11, d=trigger_pivot_diameter);
  
  // Lug to stop rearward movement of trigger.
  translate([block_height/2-7, 16.7, 0])
    chamfered_cube([7, 7, block_width], 0.6);
}

trigger_height = 70;

module trigger() {  
  difference() {
    union() {
      linear_extrude(trigger_height)
        wedge_2d();
      
      hull() {
        translate([0, catch_link_length/2, trigger_height]) {
          rotate([90, 0, 90])
            translate([0, 0, -hook_width/2])
              cylinder(hook_width, r=wedge_block_length+catch_link_length/2);
        
          // Add fillets underneath to aid in printing.
          translate([0, catch_link_length/2-1, -12])
            cube(eps, center=true);
        }
      }
    }
    
    translate([0, catch_link_length/2, trigger_height])
      rotate([90, 0, 90])
        translate([0, 0, -hook_width/2-eps])
          cylinder(hook_width+2*eps, d=trigger_pivot_diameter+loose);
  }
}

module catch_preview() {
  translate([0, receiver_housing_length-48.7, block_width]) {
    color("green")
      rotate([90, 0, -90])
        translate([0, 0, -catch_height/2])
          catch();
  
    color("red")
      translate([trigger_height-block_height, 0, 0])
        rotate([180, -90, 180])
          translate([0, 0, -block_height/2])
            trigger();
    
    color("blue")
      translate([0, -84.5, 0])
        rotate([-90, -90, 0])
          bolt();
  }
}

//projection(cut=true)
//translate([0, 0, -43])
//rotate([90, 0, 0])
{
  receiver();
  catch_preview();
}
