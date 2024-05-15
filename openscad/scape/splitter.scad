hex_diam = 38.4;
hex_spacing = 82.8 - hex_diam;

module hex_2d() {
  circle(d=hex_diam*sqrt(4/3), $fn=6);
}

module two_hexes_2d() {
  hex_2d();
  translate([0, hex_spacing]) hex_2d();
}

module test_2d() {
  $fn = 32;
  difference() {
    offset(5) two_hexes_2d();
    offset(0.3) two_hexes_2d();
  }
}

module test() {
  linear_extrude(0.2) offset(-0.2) test_2d();
  translate([0, 0, 0.2]) linear_extrude(2) test_2d();
}

test();