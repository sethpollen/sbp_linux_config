include <barrel.scad>
include <common.scad>

module spacer() {
  width = barrel_height+14;
  length = 26;
  
  zip_tie_width = 6;

  difference() {
    translate([-width/2, -length/2, 0])
      cube([barrel_height+14, length, barrel_width/2+7]);
    
    barrel_cutout();
    
    // Slot for zip tie.
    translate([0, 0, -width*0.13]) {
      rotate([90, 0, 0]) {
        translate([0, 0, -zip_tie_width/2]) {
          linear_extrude(zip_tie_width) {
            $fa = 4;
            difference() {
              circle(d=2*width);
              circle(d=width*1.25);
            }
          }
        }
      }
    }
  }
}

module spacer_print() {
  rotate([180, 0, 0])
    spacer();
}

spacer_print();
