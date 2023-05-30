// For convenience, everything below is specified in
// sixteenths of an inch. I convert to millimeters at
// the outermost scope.
to_mm = 16.0 / 25.4; // TODO: actually do this

//scale([to_mm, to_mm, to_mm]) {
  difference() {
    translate([0, 0, 4])
      scale([1, 1, -1])
        flare([13, 18, 4]);
    translate([0, 0, -0.001])
      flare([3, 8, 4.002]);
  }
//}