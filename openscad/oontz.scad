$fn = 60;

triangle_side = 105;
limit_radius = 41;

module speaker_cavity_2d() {
  intersection() {
    circle(limit_radius);
    hull()
      for (a = [0, 120, 240])
        rotate([0, 0, a])
          translate([triangle_side * sqrt(3) / 3, 0])
            square(0.001, center=true);
  }
}

wall = 1.5;
flor = 1;

linear_extrude(flor)
offset(wall) speaker_cavity_2d();

translate([0, 0, flor])
linear_extrude(15)
difference() {
  offset(wall) speaker_cavity_2d();
  speaker_cavity_2d();
}