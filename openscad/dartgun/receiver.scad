include <common.scad>
include <barrel.scad>
include <block.scad>
include <bolt.scad>

catch_gap_height = catch_height + extra_loose + 0.1;
receiver_housing_length = 54.4;

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
      cube([catch_gap_height, receiver_housing_length-3.2+2*eps, barrel_width]);
    
    // Space for the hook on the back of the bolt.
    translate([-(main_bore+1)/2, -eps, block_width-3.5+eps])
      cube([main_bore+1, 7, 3.5]);
    
    // Room for the catch between its main cavity and the pit.
    translate([0, receiver_housing_length-11, block_width])
      cube([catch_gap_height, 10, catch_spring_thickness*2 + 3], center=true);
    
    // Pit for the bar on the back of the catch.
    pit_x = catch_height + loose;
    pit_y = catch_block_length + loose;
    pit_z = catch_block_width/2 + loose;
    translate([-pit_x/2, receiver_housing_length-6.2-pit_y/2, block_width-pit_z+eps])
      cube([pit_x, pit_y, pit_z]);
    
    // Cavity for trigger to move through.
    translate([-block_height/2-eps, 2.5, block_width+eps])
      scale([1, 1, -1])
        flare_cube([block_height+2*eps, 14.2, hook_width/2], -0.5);
        
    // Cavity for ring at top of trigger.
    translate([-block_height/2-eps, trigger_pivot_offset, block_width - hook_width/2])
      cube([15, 10, 10]);

    // Zip tie aids.
    translate([0, -12, 0])
      zip_tie_aids();
      
    // Remove unnecessary exterior volume.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([7, receiver_housing_length-28, -eps])
          cube(40);
  }
  
  // Trigger pivot lug.
  translate([-block_height/2, trigger_pivot_offset, 6])
    cylinder(5, 0, trigger_pivot_diameter/2);
  translate([-block_height/2, trigger_pivot_offset, 11])
    cylinder(block_width-11, d=trigger_pivot_diameter);
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
  translate([0, receiver_housing_length-46.7, block_width]) {
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
  //catch_preview();
}
