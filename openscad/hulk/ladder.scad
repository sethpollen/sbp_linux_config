eps = 0.001;
layer = 0.2;

width = 29; 
height = 7.8;

module exterior_2d() {
  difference() {
    square([width, width], center=true);
    
    // Chamfer corners.
    for (a = [-1, 1], b = [-1, 1])
      scale([a, b])
        translate([width/2, width/2])
          rotate([0, 0, 45])
            square(4, center=true);
  }
}

module exterior() {
  linear_extrude(layer)
    offset(-0.2)
      exterior_2d();
  translate([0, 0, layer])
    linear_extrude(height - layer)
      exterior_2d();
}

module down() {
  stair_width = 0.4;
  
  difference() {
    exterior();
    
    translate([-width*0.1, 0, 0]) {
      for (s = [0:4])
        translate([2*s, 0, 2*s - eps])
          linear_extrude(height*2)
            square(width * [0.25, stair_width], center=true);
    
      translate([-3, 0, 0])
        rotate([0, 45, 0])
          cube([7, width*stair_width, 7], center=true);
    }
  }
}

down();