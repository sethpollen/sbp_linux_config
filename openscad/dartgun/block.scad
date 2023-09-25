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
