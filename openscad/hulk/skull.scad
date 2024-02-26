use <stack.scad>

eps = 0.0001;
skull_depth = 1.4;

module skull_2d() {
  $fn = 30;
  
  scale(0.98 * [1, 1]) {
    difference() {
      union() {
        translate([0, -0.5])
          circle(d=13.5);
        translate([0, -5])
          square([10, 6], center=true);
      }
      
      // Eyeballs.
      for (x = 3 * [-1, 1])
        translate([x, -1.8])
          circle(d=3.6);
      
      // Nose.
      translate([0, -3]) {
        hull() {
          square(eps, center=true);
          translate([0, -2.8])
            square([3.4, eps], center=true);
        }
      }
    }
    
    // Angry eyes.
    for (a = [-1, 1])
      scale([a, 1])
        translate([2, -8.8])
          translate([0, 10])
            rotate([0, 0, 20])
              square(5, center=true);
    
    // Teeth.
    for (x = [-4.2, -1.39, 1.39, 4.2])
      translate([x, -8])
        square([1.6, 3], center=true);
  }
}

module skull_inlay() {
  stack(0.2) {
    offset(-0.45) skull_2d();
    stack(skull_depth - 0.8) {
      offset(-0.2) skull_2d();
    }
  }
}

module skull_cavity() {
  linear_extrude(0.2)
    offset(0.26)
      skull_2d();
  linear_extrude(skull_depth)
    skull_2d();
}

skull_cavity();