eps = 0.00001;
$fn = 60;

hole_diam = 33.8;

rows = 2;
cols = 2;

// Interior is about 295mm by 235mm.
//   (295-7*33)/8 = 8
//   (235-6*33)/7 = 5.2
// So a gap of 5mm seems reasonable.
gap = 5;

wall = 3.8;
flange = 3.5;

hole_depth = 3.2;
floor_height = 1;
height = floor_height + hole_depth; 

module gridify() {
  for (r = [1:rows], c = [1:cols])
    translate([(c-1) * (hole_diam+gap), (r-1) * (hole_diam+gap)])
      children();
}

module floor() {
  difference() {
    offset(wall)
      gridify() circle(d=hole_diam);
    offset(-flange)
      gridify() circle(d=hole_diam);
  }
}

module wall() {
  difference() {
    offset(wall)
      gridify() circle(d=hole_diam);
    gridify() circle(d=hole_diam);
  }
}

module main() {
  linear_extrude(0.2)
    offset(-0.3)
      floor();
  translate([0, 0, 0.2])
    linear_extrude(floor_height - 0.2)
      floor();
translate([0, 0, floor_height])
  linear_extrude(hole_depth)
    wall();
}

main();