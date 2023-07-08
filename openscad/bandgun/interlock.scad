$fa = 5;
$fs = 0.2;
eps = 0.001;

module socket() {
  intersection() {
    translate([0, 1, 0]) square([7.5, 2], center=true);
    difference() {
      union() {
        for (x = [-2, 2])
          translate([x, 0, 0]) circle(2);
        translate([0, 1, 0]) square(2, center=true);
      }
      translate([0, 3.46, 0]) circle(2);
    }
  }
}

translate([-9.5, 0, 0]) {
  linear_extrude(6) {
    translate([6.5-eps, 0, 0]) square([6, 48], center=true);
    for (a = [-1, 1]) {
      scale([1, a, 1]) {
        translate([0, -20, 0]) socket();
        translate([0, -22+eps, 0]) square([7.5, 4], center=true);
      }
    }
  }
}

translate([-2.5, 0, 20]) {
  linear_extrude(6) {
    translate([0, 0, 0]) square([5, 34], center=true);
    for (y = [-16.5, 16.5])
      translate([0, y, 0]) circle(2);
  }
}