use <skull.scad>

eps = 0.0001;

diameter = 27;
height = 3.8;

module hex_chip_2d() {
  roundoff = 0.2;
  offset(roundoff)
    circle(d=diameter-2*roundoff, $fn=6);
}

skull_scale = 1.05;

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

    if (skull)
      translate([0, -0.5, 0])
        scale([skull_scale, skull_scale, 1])
          skull_cavity();
    else
      translate([0, 0, -eps])
        linear_extrude(2, scale=0)
          circle(2.3, $fn=20);

    for (a = [0:5]) {
      rotate([0, 0, a*60]) {
        translate([17, 0, -3])
          rotate([0, 60, 0])
            cube(10, center=true);
        translate([16.9, 0, height+3])
          rotate([0, 45, 0])
            cube(10, center=true);
      }
    }
  }
}

module scaled_skull_inlay() {
  scale([skull_scale, skull_scale, 1])
    skull_inlay();
}

hex_chip(true);
