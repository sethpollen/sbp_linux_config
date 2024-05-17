hex_diam = 38.4;
hex_spacing = 82.8 - hex_diam;
slack = 0.25;
wall = 0.95;

module hex_2d() {
  circle(d=hex_diam*sqrt(4/3), $fn=6);
}

module joint_2d() {
  translate([0, hex_spacing/2])
    square([hex_diam*sqrt(1/3), hex_spacing], center=true);
}

module exterior_2d() {
  offset(slack + wall, $fn=16) {
    for (a = [0:3])
      translate([0, a*hex_spacing])
        hex_2d();
    
    for (a = [0:2])
      translate([0, a*hex_spacing])
        joint_2d();
    
    for (a = [0:2])
      translate([0, (3+a)*hex_spacing])
        rotate([0, 0, 60])
          translate([0, hex_spacing])
            hex_2d();
    
    translate([0, 3*hex_spacing])
      rotate([0, 0, 60])
        joint_2d();
  }
}

exterior_2d();

/*
module test_2d() {
  $fn = 32;
  difference() {
    offset(1.2) two_hexes_2d();
    offset(0.3) two_hexes_2d();
  }
}

module test() {
  linear_extrude(0.2) offset(-0.2) test_2d();
  translate([0, 0, 0.2]) linear_extrude(2) test_2d();
}

test();
*/