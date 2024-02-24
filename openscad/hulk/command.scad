eps = 0.001;

module skull_2d() {
  $fn = 30;
  
  difference() {
    union() {
      translate([0, -0.5])
        circle(d=13.5);
      translate([0, -5])
        square([10, 6], center=true);
    }
    
    // Eyeballs.
    for (x = 3 * [-1, 1])
      translate([x, -2])
        circle(d=3.5);
    
    // Nose.
    translate([0, -3]) {
      hull() {
        square(eps, center=true);
        translate([0, -2.4])
          square([2.5, eps], center=true);
      }
    }
  }
  
  // Angry eyes.
  for (a = [-1, 1])
    scale([a, 1])
      translate([2, -9])
        translate([0, 10])
          rotate([0, 0, 20])
            square(5, center=true);
  
  // Teeth.
  for (x = [-4, -1.3, 1.3, 4])
    translate([x, -8])
      square([2, 3], center=true);
}

skull_2d();