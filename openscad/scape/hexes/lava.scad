module imp() {
  translate([0, 0, 4.8265])
    scale(25.4 * [1, 1, 1])
      rotate([-90, 0, 0])
        import("originals/glacier_1hex.stl", 5);
}

module bottom_2d() {
  projection(cut=true)
    translate([0, 0, -0.1])
      imp();
}

difference() {
  imp();
  
  translate([-500, -500, -1000 + 0.4])
    cube(1000);
}

linear_extrude(0.2)
  offset(-0.5)
    bottom_2d();

translate([0, 0, 0.2])
  linear_extrude(0.2)
    offset(-0.05)
      bottom_2d();
