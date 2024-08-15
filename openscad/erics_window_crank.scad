eps = 0.001;

spline_count = 12;

spline_id_max = 7.7;
spline_id_min = 6.2;
shaft_od = 11.6;

module spline_2d() {
  difference() {
    $fn = 40;
    circle(d=shaft_od);
    circle(d=spline_id_min);
    intersection() {
      circle(d=spline_id_max);
      for (a = [0:5])
        rotate([0, 0, a*30])
          square([100, 1], center=true);
    }
  }
}

rotate([45, 0, 0])
  linear_extrude(15)
    spline_2d();

