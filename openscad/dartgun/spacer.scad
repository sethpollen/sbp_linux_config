include <barrel.scad>
include <common.scad>

module spacer() {
  width = barrel_height + 14;
  length = 26;
  height = barrel_width/2 + 7;
  
  zip_tie_width = 6;

  difference() {
    translate([-width/2, -length/2, 0])
      cube([barrel_height+14, length, height]);
    
    // Leave a slight gap between the spacers so they fit tightly.
    translate([0, 0, -0.2])
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
    
    // Slot to make it easy to cut the zip tie.
    translate([0, 0, height])
      cube([5, 10, 4], center=true);
  }
}

module spacer_print() {
  rotate([180, 0, 0])
    spacer();
}

spacer_print();
