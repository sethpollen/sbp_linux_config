$fn = 25;
eps = 0.0001;

r = 4.6;
groove = 0.4;
r_curvature = 25;
segment_angle = 12;
groove_angle = 1;
segments = 11;

module turn(a) {
  translate([r_curvature, 0, 0])
    rotate([0, a, 0])
      translate([-r_curvature, 0, 0])
        children();
}

module segment() {
  hull() {
    cylinder(r=r-groove, h=eps);
    turn(groove_angle)
      cylinder(r=r, h=eps);
    turn(segment_angle-groove_angle)
      cylinder(r=r, h=eps);
    turn(segment_angle+0.01)
      cylinder(r=r-groove, h=eps);
  }
}

module arm() {
  for (i = [0:segments-1])
    turn(i*segment_angle)
      segment();
}

module claw() {
  for (a = [0, 120, 240]) {
    rotate(a) {
      translate([r-1, 0, 0]) {
        rotate([0, 50, 0]) {
          cube([2.7, 5, 10], center=true);
          
          translate([0, 0, 4.5])
            rotate([0, -60, 0])
              translate([-0.05, 0, 2.05])
                cube([2.3, 5, 6], center=true);
        }
      }
    }
  }
}

module piece() {
  mirror([0, 0, 1]) {
    arm();
    turn(segments*segment_angle)
      sphere(r+1.1, $fn=36);
  }
  claw();
}

piece();