module flare(dims) {
  hull()
    for (a = [-1, 1], b = [-1, 1])
      translate([dims.x*a/2, dims.y*b/2, dims.z])
        scale([1, 1, -1])
          linear_extrude(dims.z, scale=0)
            square(dims.z*2, dims.z*2, center=true);
}

// For convenience, everything below is specified in
// sixteenths of an inch. I convert to millimeters at
// the outermost scope.
to_mm = 16.0 / 25.4;

scale([to_mm, to_mm, to_mm]) {
  difference() {
    translate([0, 0, 4])
      scale([1, 1, -1])
        flare([13, 18, 4]);
    translate([0, 0, -0.001])
      flare([3, 8, 4.002]);
  }
}