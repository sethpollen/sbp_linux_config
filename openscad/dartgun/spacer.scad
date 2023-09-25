// TODO: use block.scad

include <barrel.scad>
include <block.scad>
include <common.scad>

module spacer() { 
  zip_tie_width = 6;

  difference() {
    block(26);
    
    // Slot for zip tie.
    translate([0, 0, block_width*1.35]) {
      rotate([90, 0, 0]) {
        translate([0, 0, -zip_tie_width/2]) {
          linear_extrude(zip_tie_width) {
            $fa = 4;
            difference() {
              circle(d=2*block_height);
              circle(d=block_height*1.25);
            }
          }
        }
      }
    }
    
    // Slot to make it easy to cut the zip tie.
    cube([5, 10, 4], center=true);
  }
}

spacer();
