eps = 0.0001;
$fn = 20;

square_side = 29;

socket_offset = 0.2;
roundoff = 0.7;

module lug_2d() {
  translate([-square_side/2 -3, 0]) {
    hull() {
      translate([12, 0])
        square(eps, center=true);
      square([eps, 9], center=true);
    }
  }
}

module piece_2d(recede) {
  offset(roundoff) {
    offset(-roundoff-recede) {
      difference() {
        union() {
          square(square_side, center=true);
          for (a = [0, 90])
            rotate([0, 0, a])
              lug_2d();
        }
        for (a = [0, 90])
          rotate([0, 0, a])
            translate([square_side, 0])
              offset(socket_offset)
                lug_2d();
      }
    }
  }
}

height = 3.4;
layer = 0.2;
chamfer = 1;

module piece() {
  // Bottom 2 layers: Extra chamfer for elephant foot.
  linear_extrude(layer)
    piece_2d(chamfer + 0.5*layer);
  translate([0, 0, layer])
    linear_extrude(layer)
      piece_2d(chamfer - 1.5*layer);

  for (z = [2*layer : layer : chamfer - layer])
    translate([0, 0, z])
      linear_extrude(layer)
        piece_2d(chamfer - layer - z);

  translate([0, 0, chamfer])
    linear_extrude(height - chamfer - chamfer)
      piece_2d(0);

  for (z = [0 : layer : chamfer - layer])
    translate([0, 0, height - chamfer + z])
      linear_extrude(layer)
        piece_2d(z);
}

for (a = [0:3])
  rotate([0, 0, a*90])
    translate((square_side/2+4) * [1, 1])
      piece();

cube(cube_square_side);
      