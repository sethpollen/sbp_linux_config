include <barrel.scad>
include <block.scad>
include <common.scad>

module spacer() { 
  difference() {
    block(26);
    zip_tie_aids();
  }
}

spacer();
