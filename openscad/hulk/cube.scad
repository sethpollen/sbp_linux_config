module octahedron(s, flat=true) {
  translate([0, 0, flat ? s*0.4082 : 0])
    rotate([flat ? 109.47122/2 : 0, 0, 0])
      for (a = [-1, 1])
        scale([1, 1, a])
          linear_extrude(s*sqrt(2)/2, scale=0)
            square(s, center=true);
}

module cube() {
  cube_side = 8;
  intersection() {
    linear_extrude(cube_side)
      square(cube_side, center=true);
    translate([0, 0, cube_side/2])
      rotate([0, 0, 45])
        octahedron(cube_side*1.94, false);
  }
}

module turn() {
  translate([0, 0, 0.4]) 
    rotate([54.8, 0, 0])
      rotate([0, 0, 45])
        translate([4, 4, 0])
          children();
}

module print() {
  linear_extrude(0.2)
    offset(-0.25)
      projection(cut=true)
        translate([0, 0, -0.1])
          children();
  
  difference() {
    children();
    translate([0, 0, -0.001])
      linear_extrude(0.2)
        square(1000, center=true);
  }
}

turn() cube();
//cylinder(h=8, d=12);