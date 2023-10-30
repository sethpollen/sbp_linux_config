module piece() {
  translate([0, 0, -56.2])
    import("main_body_horzontal_cut_R.stl", convexity = 1);
}

module silhouette() {
  projection() {
    intersection() {
      piece();
      cube([1000, 1000, 0.4]);
    }
  }
}

linear_extrude(0.4) {
  difference() {
    offset(6) silhouette();
    offset(0.05) silhouette();
  }
}