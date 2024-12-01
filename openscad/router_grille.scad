$fn = 200;

wall = 2;
id = 2 * (11 + 11/16) * 25.4;
height = 40;

module piece_2d(angle) {
  intersection() {
    difference() {
      circle(d=id+2*wall);
      circle(d=id);
    }
    polygon(1000 * [
      [0, 0],
      [1, 0],
      [cos(angle), sin(angle)],
    ]);
  }
}

module tag() {
  // Floor.
  linear_extrude(0.6)
    translate([(id+wall)/2, 0])
      square([40, 8], center=true);
  
  // Riser.
  linear_extrude(10)
    for (x = [-wall/2-6, wall/2+6])
      translate([(id+wall)/2 + x, 0.4])
        square([5, 1.8], center=true);
    
  // Bridge.
  translate([(id+wall)/2, 0.4, 8])
    linear_extrude(4)
      square([16 + wall, 0.8], center=true);
}

module piece(angle) {
  linear_extrude(height)
    offset(-0.35)
      piece_2d(angle);
  translate([0, 0, 0.2])
    linear_extrude(height-0.2)
      piece_2d(angle);
  
  tag();
  rotate([0, 0, angle])
    mirror([0, 1, 0])
      tag();
}

translate([-id/2, 0])
  piece(45);