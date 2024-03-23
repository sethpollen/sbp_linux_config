// Exterior dimensions.
width = 70;
height = 57;
length = 200;

div_height = 40;
chamfer_radius = 1;
wall = 2;

eps = 0.0001;

module exterior() {
  hull() {
    $fn = 16;
    for (x = (width/2 - chamfer_radius) * [-1, 1], y = [chamfer_radius, length - chamfer_radius]) {
      translate([x, y]) {
        translate([0, 0, chamfer_radius])
          sphere(chamfer_radius);
        translate([0, 0, height])
          linear_extrude(eps)
            circle(chamfer_radius);
      }
    }
  }
}

module cavities() {
  cavs = 5;
  cav_width = width - 2*wall;
  cav_length = (length - wall * (cavs + 1)) / cavs;
  
  for (a = [0:cavs-1])
    translate([-cav_width/2, wall + a * (wall + cav_length), wall])
      cube([cav_width, cav_length, 100]);
  
  translate([-cav_width/2, wall, div_height])
    cube([cav_width, length - 2*wall, 100]);
}

module notch() {
  $fn = 50;
  radius = 11;
  
  translate([0, 0, height + radius*0.3])
    rotate([-90, 0, 0])
      translate([0, 0, -1])
        cylinder(h=length+2, r=radius);
}

module box() {
  difference() {
    exterior();
    cavities();
    notch();
  }
}

module floral() {
  surface("floral.png");
}

floral();