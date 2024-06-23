$fn = 30;

module profile() {
  circle(d=10);
  translate([8, 0])
    circle(d=10);
}

hull() {
  linear_extrude(0.00001)
    profile();
  translate([0, 0, 1.3])
    linear_extrude(0.00001)
      offset(-0.3)
        profile();
}