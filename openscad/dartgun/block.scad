include <barrel.scad>
include <common.scad>

block_height = barrel_height + 14;
block_width = barrel_width/2 + 7;

module block(length) {
  translate([0, 0, block_width]) {
    rotate([180, 0, 0]) {
      difference() {
        translate([-block_height/2, -length/2, 0])
          cube([block_height, length, block_width]);
        
        barrel_cutout();
      }
    }
  }
}

zip_tie_width = 6;

module zip_tie_aids() {
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