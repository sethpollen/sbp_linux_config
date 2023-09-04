include <common.scad>

notch_depth = 2.2;
notch_length = 4;

// lug_type 0 means no lug. 1 means beveled. 2 means square.
module rail_lug_2d(width, stem, lug_type) {
  translate([0, -stem/2, 0])
    square([width, stem], center=true);
  
  difference() {
    hull()
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([width/2, 0, 0])
            rotate([0, 0, 45])
              square(notch_depth*sqrt(2), center=true);
    
    if (lug_type == 0)
      translate([0, notch_depth])
        square([width+notch_depth*4, notch_depth*2], center=true);
  }
  
  if (lug_type == 2)
    translate([0, notch_depth/2, 0])
      square([width + notch_depth*2, notch_depth], center=true);
}

module rail(width, length, stem, cavity=false) {
  repeats = floor(length / (2*notch_length));
  
  intersection() {
    cube([width*2, width*2, length*2], center=true);
    
    for (a = [0:repeats]) {
      translate([0, 0, a*2*notch_length]) {
        difference() {
          // High piece.
          translate([0, 0, cavity ? -snug/2 : 0])
            linear_extrude(notch_length+eps + (cavity ? snug : 0))
              offset(cavity ? snug : 0)
                rail_lug_2d(width, stem, cavity ? 2 : 1);

          // Chamfer edges.
          if (!cavity)
            for (z = [0, notch_length])
              translate([0, notch_depth, z])
                hull()
                  rotate([45, 0, 0])
                    cube([width*2, foot*sqrt(2), foot*sqrt(2)], center=true);
        }

        // Low piece.
        translate([0, 0, notch_length])
          linear_extrude(notch_length+eps)
            offset(cavity ? snug : 0)
              rail_lug_2d(width, stem, 0);      
      }
    }
  }
}

rail(20, 9, 6, cavity=true);