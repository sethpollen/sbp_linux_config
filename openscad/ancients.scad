eps = 0.0001;
$fn = 16;

hex_side = 32;
thickness = 2.4;

clasp_width = 5;
clasp_length = 2.7;
slack = 0.15;

ear_thickness = 0.2 - eps;

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
      for (r = 60 * lugs)
        rotate([0, 0, r])
          clasp_lug_2d();
    }
    for (r = 60 * lugs)
      rotate([0, 0, r])
        clasp_socket_2d();
  }
}

groove_depth = 0.85;

module groove() {
  magnitude = groove_depth * sqrt(2);
  
  hull()
    for (dy = [-0.1, 0.1])
      translate([0, hex_side*sqrt(3)/2 + dy, thickness])
        rotate([45, 0, 0])
          cube([hex_side+1, magnitude, magnitude], center=true);
}

module piece(lugs=[]) {
  difference() {
    union() {
      linear_extrude(thickness)
        piece_2d(lugs=lugs);
      
      // Rabbit ears.
      linear_extrude(ear_thickness) {
        for (r = 60 * lugs) {
          rotate([0, 0, r]) {
            translate([0.3, 0])
              square([clasp_width-0.5, hex_side + 2]);
            translate([0.2 - 2*clasp_width, 0])
              square([clasp_width-0.5, hex_side - 1]);
          }
        }
      }
    }
    
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

module small_piece(lugs=[true, true, true, true]) {
  piece();
  
  for (a = [0:5]) {
    rotate([0, 0, a*60]) {
      joint();
      
      translate([0, hex_side * sqrt(3)])
        rotate([0, 0, 120])
          joint();
      
      translate([0, spacing])
        piece(
          (a == 0 && lugs[0])? [1, 5]
          : (a == 1 && lugs[1]) ? [1]
          : (a == 2 && lugs[1]) ? [5]
          : (a == 3 && lugs[2]) ? [1, 5]
          : (a == 4 && lugs[3]) ? [1]
          : (a == 5 && lugs[3]) ? [5]
          : []
        );
      
      // Rabbit ears.
      linear_extrude(ear_thickness)
        for (b = [-1, 1])
          scale([b, 1])
            translate([0.2 - hex_side/2, 0])
              square([5, hex_side*2.61 + 5]);
    }
  }
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

print() small_piece();
