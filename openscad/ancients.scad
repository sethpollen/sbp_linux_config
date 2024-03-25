eps = 0.0001;
$fn = 16;

hex_side = 13;  // TODO: real value is 32
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

module piece_2d(lugs=[]) {
  difference() {
    union() {
      hex_2d();
      for (r = 60 * lugs) rotate([0, 0, r])
        clasp_lug_2d();
    }
    for (r = 60 * lugs) rotate([0, 0, r])
      clasp_socket_2d();
  }
}

groove_depth = 0.85;

module groove() {
  magnitude = groove_depth * sqrt(2);
  
  translate([0, hex_side*sqrt(3)/2, thickness])
    rotate([45, 0, 0])
      cube([hex_side+1, magnitude, magnitude], center=true);
}

module piece(lugs=[]) {
  difference() {
    linear_extrude(thickness)
      piece_2d(lugs=lugs);
    
    for (a = [0:60:300])
      rotate([0, 0, a])
        groove();
  }
}

joint_width = 0.1;
spacing = hex_side * sqrt(3) + joint_width;

module joint() {
  linear_extrude(thickness - groove_depth)
    translate([-hex_side/2, hex_side * sqrt(3) / 2 - 0.1])
      square([hex_side, 0.2 + joint_width]);
}

module one_piece() {
  piece([4, 5]);
}

module two_pieces() {
  piece([1]);

  translate([0, spacing])
    piece([2]);
  
  joint();
}

module three_pieces() {
  piece([1,3]);
  
  translate([0, spacing])
    piece([4]);
  
  rotate([0, 0, -120])
    translate([0, spacing])
      piece([2]);
  
  // Joints.
  for (a = [0, -120])
    rotate([0, 0, a])
      joint();
}

module print() {
  linear_extrude(0.2)
    offset(-0.3)
      projection(cut=true)
        translate([0, 0, -0.1])
          children();
  intersection() {
    children();
    translate([0, 0, 500.2])
      cube(1000, center=true);
  }
}

module test1() {
  intersection() {
    union() {
      rotate([0, 0, 60])
        three_pieces();
      translate([0, 33])
        rotate([0, 0, 60])
          three_pieces();
    }
    
    translate([0, 22, 0])
      cube([40, 37, 100], center=true);
  }
}

module test2() {
  intersection() {
    union() {
      translate([-28, 11])
        one_piece();

      two_pieces();
    }
    
    translate([-13, 11, 0])
      cube([30, 33, 100], center=true);
  }
}

print() {
  test1();
  translate([55, 0, 0]) test2();
}