eps = 0.001;
$fn = 16;

hex_side = 18;  // TODO: real value is 32
thickness = 2.4;

clasp_width = 4;
clasp_length = 2.5;
slack = 0.15;

module hex_2d() {
  polygon([for (r = [0:60:300]) hex_side * [cos(r), sin(r)]]);
}

module clasp_lug_2d() {
  translate([0, hex_side*sqrt(3)/2])
    square([clasp_width, clasp_length]);
}

module clasp_socket_2d() {
  offset(slack)
    translate([-clasp_width, hex_side*sqrt(3)/2 - clasp_length])
      square([clasp_width, 2*clasp_length]);
}

module piece_2d() {
  difference() {
    union() {
      hex_2d();
      for (r = [0:60:300]) rotate([0, 0, r])
        clasp_lug_2d();
    }
    for (r = [0:60:300]) rotate([0, 0, r])
      clasp_socket_2d();
  }
}

module piece() {
  layer = 0.2;
  chamfer_layers = 5;
  slope = 0.7;
  
  for (l = [0:chamfer_layers-1]) {
    z = (chamfer_layers-l-1)*layer;
    translate([0, 0, z])
      linear_extrude(layer)
        offset(-(l+1)*layer*slope - (z == 0 ? 0.2 : 0))
          piece_2d();
  }
  
  translate([0, 0, chamfer_layers * layer])
    linear_extrude(thickness - chamfer_layers * layer)
      piece_2d();
}

piece();