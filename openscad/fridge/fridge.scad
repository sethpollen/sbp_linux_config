module fridge() {
  color("#7b9fb3")
  import("Retro_Fridge.stl", 5);
}

module smeg() {
  color("white")
  translate([1.6, 5.15, 29])
  rotate([90, 0, 0])
  linear_extrude(4)
  scale([1.4, 1] * 0.17)
  offset(delta=0.5)
  text("S   M   E   G", font="Aegyptus");
}

module longevity() {
  color("white")
  translate([14.5, 8.7, 30])
  rotate([0, 90, 0])
  linear_extrude(4)
  scale([1, 1] * 0.45)
  text("longevity", font="Alexander");
}

module reliability() {
  color("white")
  translate([3.5, 11.5, 31.5])
  rotate([0, 90, 180])
  linear_extrude(4)
  scale([1, 1] * 0.45)
  text("reliability", font="Alexander");
}

smeg();
fridge();
longevity();
reliability();
