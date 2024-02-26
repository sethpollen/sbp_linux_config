use <skull.scad>

eps = 0.0001;

diameter = 27;
height = 3.8;

module hex_chip_2d() {
  roundoff = 0.2;
  offset(roundoff)
    circle(d=diameter-2*roundoff, $fn=6);
}

module hex_chip(skull=false) {
  difference() {
    union() {
      linear_extrude(0.2 + eps)
        offset(-0.8)
          hex_chip_2d();

      translate([0, 0, 0.2])
        linear_extrude(0.2 + eps)
          offset(-0.3)
            hex_chip_2d();
      
      translate([0, 0, 0.4])
        linear_extrude(height - 0.4)
          hex_chip_2d();
    }

    translate([0, -0.5, 0])
      scale([1.05, 1.05, 1])
        skull_cavity();
  }
}

hex_chip();