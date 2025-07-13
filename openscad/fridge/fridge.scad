module fridge() {
  import("Retro_Fridge.stl", 5);
}

module smeg() {
  color("blue")
  translate([1.6, 5.15, 29])
  rotate([90, 0, 0])
  linear_extrude(4)
  scale([1.4, 1] * 0.17)
  offset(delta=0.5)
  text("S   M   E   G", font="Aegyptus");
}

smeg();
fridge();