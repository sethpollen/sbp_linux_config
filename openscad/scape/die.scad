// Original dice are 14mm across and way 4g each.

eps = 0.001;

s = 14;
chamfer = 1;
engrave_depth = 1.2;

module exterior() {
  hull() {
    for (a = [-1, 1], b = [-1, 1], c = [-1, 1]) {
      scale([a, b, c]) {
        translate((s/2 - chamfer) * [1, 1, 1]) {
          sphere(chamfer, $fn=32);
        }
      }
    }
  }
}

module claw_2d() {
  width = 12;
  height = 33;
  polygon([
    [-width/2, 0],
    [-width/16, height],
    [width/16, height],
    [width/2, 0]
  ]);
}

module hit_2d() {
  scale(s * 0.01 * [1, 1]) {
    translate([5, 0]) {
      for (a = 13 * [-1, 0, 1])
        translate([a, 0])
          claw_2d();
      translate([-22, -20])
        rotate([0, 0, 20])
          claw_2d();
      polygon([
        [-19, 0],
        [-19.5, -15],
        [-27.7, -22],
        [-23, -34],
        [15, -34],
        [18, -30],
        [19, 0],
      ]);
    }
  }
}

module hit() {
  linear_extrude(engrave_depth)
    rotate([0, 0, 180])
      offset(0.3, $fn=12)
        hit_2d();
}

module miss_2d() {
  $fn = 70;
  
  scale(1.65 * [1, 1]) {
    translate([0, -0.4]) {
      intersection() {
        intersection_for(a = [-1, 1])
          scale([a, 1])
            translate([1, 0])
              circle(3.2);
        
        translate([0, 5])
          square([4, 10], center=true);
      }
      
      translate([-2, -1.7])
        square([4, 1.7]);
    }
  }
}

module miss() {
  linear_extrude(engrave_depth)
    rotate([0, 0, -90])
      offset(0.3, $fn=12)
        miss_2d();
}

module die() {
  difference() {
    exterior();
    
    for (a = [0, 90, 180])
      rotate([0, 0, a])
        rotate([90, 0, 0])
          translate([0, 0, s/2 - engrave_depth])
            hit();
    
    for (a = [0, -90])
      rotate([0, a, 0])
        translate([0, 0, s/2 - engrave_depth])
          miss();
  }
}

die();