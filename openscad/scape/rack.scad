use <figure_base.scad>

eps = 0.00001;
$fn = 50;

hole_diam = 33.5;

// True for a rack for small peanut bases.
double = false;

rows = 3;
cols = 3;

gap_x = 5;
gap_y = 9.2;
wall = 5.6;

flange = 3.5;

hole_depth = 3.2;
floor_height = 1;
height = floor_height + hole_depth; 

module gridify() {
  for (r = [1:rows], c = [1:cols])
    translate([(c-1) * (hole_diam + gap_x), (r-1) * (hole_diam + gap_y)])
      children();
}

module basic_profile() {
  if (double)
    double_base_2d();
  else
    circle(d=hole_diam);
}

module floor() {
  difference() {
    gridify()
      offset(wall)
        basic_profile();
    gridify()
      offset(-flange)
        basic_profile();
  }
}

module wall() {
  difference() {
    gridify()
      offset(wall)
        basic_profile();
    gridify()
      basic_profile();
  }
}

module main() {
  difference() {
    union() {
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
    gridify() {
      // Bevel cones.
      translate([0, 0, 0.6])
        cylinder(h=floor_height, d1=hole_diam-flange*2, d2=hole_diam-flange*2+2.5);
      translate([0, 0, height - 0.8])
        cylinder(h=1.01, d1=hole_diam, d2=hole_diam+2);
    }
  }
}

main();