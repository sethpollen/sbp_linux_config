eps = 0.001;
layer = 0.2;

width = 26; 
height = 7.6;

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

module ladder() {
  stair_width = 11;
  
  difference() {
    exterior();
    
    translate([0, 0, height/2]) {
      for (a = [0, 180]) {
        rotate([0, a, 0]) {
          for (s = [0, 1])
            translate([1 + 2*s, 0, 2*s - 2*eps])
              linear_extrude(2 + 2*eps)
                square([width * 0.4, stair_width], center=true);
          
          translate([3, 0, 3.4])
            linear_extrude(2 + 2*eps, scale=1.5)
              square([width * 0.4, stair_width], center=true);
        }
      }
    }
    
    translate([-10.7, 5.7, height-3])
      rotate([0, 0, -90])
        linear_extrude(10)
          text("UP", size=6);
    
    translate([10, 11, 0]) {
      translate([0, 0, -7])
        rotate([0, 0, 90])
          linear_extrude(10)
            scale([-1, 1])
              text("DOWN", size=5.1);
      translate([0, 0, -9.8])
        rotate([0, 0, 90])
          linear_extrude(10)
            offset(0.2)
              scale([-1, 1])
                text("DOWN", size=5.1);
    }
  }
}

ladder();