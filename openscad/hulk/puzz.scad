eps = 0.0001;
$fn = 20;

square_side = 29;

socket_offset = 0.3;
roundoff = 0.7;

module lug_2d() {
  translate([-square_side/2 -3, 0]) {
    hull() {
      translate([11, 0])
        square(eps, center=true);
      square([eps, 9], center=true);
    }
  }
}

module piece_2d(recede, mark=false) {
  difference() {
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
    
    if (mark) {
      offset(recede) {
        difference() {
          circle(d=square_side*0.39);
          circle(d=square_side*0.36);
        }
      }
    }
  }
}

height = 3.2;
layer = 0.2;
top_chamfer = 1;
bottom_chamfer = 0.8;

module piece() {
  // Bottom 2 layers: Extra chamfer for elephant foot.
  linear_extrude(layer)
    piece_2d(bottom_chamfer + 0.5*layer, mark=true);
  translate([0, 0, layer])
    linear_extrude(layer)
      piece_2d(bottom_chamfer - 1.5*layer, mark=true);

  for (z = [2*layer : layer : bottom_chamfer - layer])
    translate([0, 0, z])
      linear_extrude(layer)
        piece_2d(bottom_chamfer - layer - z, mark=true);

  translate([0, 0, bottom_chamfer])
    linear_extrude(height - bottom_chamfer - top_chamfer)
      piece_2d(0);

  for (z = [0 : layer : top_chamfer - layer])
    translate([0, 0, height - top_chamfer + z])
      linear_extrude(layer)
        piece_2d(z);
  
  // Reinforcement to reduce peeling for protrusions.
  for (a = [0, -90])
    rotate([0, 0, a])
      translate([0, -14, 0.5])
        cube([5.8, 4, 1], center=true);
}

for (a = [0:3])
  rotate([0, 0, a*90])
    translate((square_side/2+4) * [1, 1])
      piece();
      