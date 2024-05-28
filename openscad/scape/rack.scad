eps = 0.00001;
$fn = 40;

hole_diam = 33.5;

rows = 3;
cols = 3;

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
      circle(d=hole_diam);
    offset(-flange)
      circle(d=hole_diam);
  }
}

module wall() {
  difference() {
    offset(wall)
      circle(d=hole_diam);
    circle(d=hole_diam);
  }
}

module main() {
  gridify() {
    linear_extrude(0.2)
      offset(-0.3)
        floor();
    
    difference() {
      translate([0, 0, 0.2])
        linear_extrude(floor_height - 0.2)
          floor();
      translate([0, 0, 0.6])
        cylinder(h=floor_height, d1=hole_diam-flange*2, d2=hole_diam-flange*2+2.5);
    }
    
    difference() {
      translate([0, 0, floor_height])
        linear_extrude(hole_depth)
          wall();
      translate([0, 0, height - 0.8])
        cylinder(h=1.01, d1=hole_diam, d2=hole_diam+2);
    }
  }
}

main();