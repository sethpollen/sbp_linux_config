eps = 0.001;
$fn = 30;
layer = 0.2;

die_cavity_width = 16.5;
cover_wall = 3;
cover_exterior_width = die_cavity_width + 2*cover_wall;

module die_cover() {
  
  difference() {
    union() {
      linear_extrude(layer)
        offset(0.7)
          square(cover_exterior_width-2, center=true);
      translate([0, 0, layer])
        linear_extrude(die_cavity_width-layer)
          offset(1)
            square(cover_exterior_width-2, center=true);
    }

    translate([0, 0, -eps])
      linear_extrude(die_cavity_width + 1)
        square(die_cavity_width, center=true);
    
    translate([0, 0, -eps])
      linear_extrude(cover_exterior_width/2, scale=0.4)
        offset(1)
          square(die_cavity_width, center=true);
  }
}

die_cover();