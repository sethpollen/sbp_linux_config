module piece() {
  translate([0, 0, -83.27])
    rotate([90, 0, 0])
      import("Sig_Sauer_P226_STL.stl", convexity = 1);
}

intersection() {
  piece();
  cube(500, center=true);
}
