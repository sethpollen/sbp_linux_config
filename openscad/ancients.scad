eps = 0.0001;
$fn = 16;

hex_side = 32;
thickness = 2.4;

clasp_width = 5;
clasp_length = 2.7;
slack = 1; // TODO: 0.15;

ear_thickness = 0.2 - eps;

stripe_thickness = 0.4;
stripe_width = 3.5;

function contains_mod_6(haystack, needle, pos=0) =
  (pos < len(haystack))
  && (
    ((needle % 6) == (haystack[pos] % 6))
    || contains_mod_6(haystack, needle, pos+1)
  );

module stripe_2d() {
  intersection() {
    square([100, stripe_width], center=true);
    offset(-2.3)
      piece_2d();
  }
}

module stripe() {
  linear_extrude(stripe_thickness)
    stripe_2d();
}

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
groove_flat = 0.15;

module groove() {
  magnitude = groove_depth * sqrt(2);
  
  hull()
    for (dy = groove_flat * [-1, 1])
      translate([0, hex_side*sqrt(3)/2 + dy, thickness])
        scale([1, 0.9, 1])
          rotate([45, 0, 0])
            cube([hex_side+1, magnitude, magnitude], center=true);
}

spacing = hex_side * sqrt(3) + slack;

module joint() {
  color("red")
    linear_extrude(thickness - groove_depth)
      translate([-hex_side/2, hex_side * sqrt(3) / 2 - 0.1])
        square([hex_side, 0.2 + slack]);
}

module plug() {
  color("blue")
    rotate([0, 0, 120])
      linear_extrude(thickness - groove_depth)
        translate([hex_side, 0])
          square(2, center=true);
}

module piece(lugs=[], joints=[]) {
  difference() {
    linear_extrude(thickness)
      piece_2d(lugs=lugs);
    
    for (a = [0:60:300])
      rotate([0, 0, a])
        groove();
  }

  // Rabbit ears for lugs.
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
  
  // Joints.
  for (r = 60 * joints)
    rotate([0, 0, r])
      joint();
  
  // Plugs wherever two joints meet.
  for (a = [0:5])
    if (contains_mod_6(joints, a) && contains_mod_6(joints, a+1))
      rotate([0, 0, a*60])
        plug();
}

large_piece();

module small_piece(lugs=[true, true, true, true], stripey=false) {
  difference() {
    union() {
      piece(joints=[0, 1, 2, 3, 4, 5]);
      
      for (a = [0:5]) {
        rotate([0, 0, a*60]) {
          translate([0, spacing])
            piece(
              lugs =
                (a == 0 && lugs[0]) ? [1, 5]
              : (a == 1 && lugs[1]) ? [1]
              : (a == 2 && lugs[1]) ? [5]
              : (a == 3 && lugs[2]) ? [1, 5]
              : (a == 4 && lugs[3]) ? [1]
              : (a == 5 && lugs[3]) ? [5]
              : [],
              joints=[4]
            );
        }
      }
    }

    // TODO:
    if (stripey) {
      translate([0, 0, thickness - stripe_thickness]) {
        linear_extrude(5) {
          for (a = [-1, 1])
            scale([a, 1])
              rotate([0, 0, 60])
                translate([0, spacing])
                  rotate([0, 0, 120])
                    offset(0.2)
                      stripe_2d();
            
          // Bridge stripe.
          translate([0, spacing/2])
            offset(0.2)
              stripe_2d();
        }
      }
    }
  }
}

// TODO: rabbit ears
// TODO: stripe
module large_piece(lugs=[true, true, true, true]) {
  piece();
  
  // Short row.
  for (a = [0:1])
    translate([0, a * spacing])
      piece(
        joints =
          (a == 0) ? [0, 1, 2, 4, 5]
        : (a == 1) ? [   1, 2, 4, 5]
        : []
      );
  
  // Long rows.
  for (a = [-1, 0, 1], b = [-1, 1])
    translate([0, a * spacing])
      rotate([0, 0, b * 60])
        translate([0, spacing])
          piece(
            lugs =
              (b == -1 && a == -1 && lugs[0]) ? [3]
            : (b ==  1 && a == -1 && lugs[0]) ? [3]
            : (b == -1 && a ==  1 && lugs[1]) ? [2]
            : (b ==  1 && a ==  1 && lugs[1]) ? [4]
            : (b == -1 && a ==  0 && lugs[2]) ? [0, 5]
            : (b ==  1 && a ==  0 && lugs[3]) ? [0, 1]
            : [],
            joints =
              (b == -1 && a == -1) ? [1]
            : (b ==  1 && a == -1) ? [5]
            : (b == -1 && a ==  1) ? [4]
            : (b ==  1 && a ==  1) ? [2]
            : []
          );
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

