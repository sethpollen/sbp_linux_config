eps = 0.00001;
$fn = 50;

hole_diam = 33.5;
hole_depth = 3.2;

fence = 6;
rows = 3;
cols = 4;
gap = 7;
extra_gap = 2;
outer_gap = 6.5;

module gridify() {
  for (r = [1:rows], c = [1:cols])
    translate([(c-1) * (hole_diam + gap), (r-1) * (hole_diam + gap + extra_gap)])
      children();
}

module fence_2d() {
  difference() {
    gridify()
      offset(fence)
        circle(d=hole_diam);
    gridify()
      circle(d=hole_diam);
  }
}

module floor_2d() {
  roundoff = 3;
  
  offset(roundoff) offset(-roundoff) {
    translate([-hole_diam/2 - outer_gap, -hole_diam/2 - outer_gap]) {
      square([
        cols*hole_diam + (cols-1)*gap + 2*outer_gap,
        rows*hole_diam + (rows-1)*(gap+extra_gap) + 2*outer_gap
      ]);
    }
  }
}

module wall_2d() {
  wall = 0.8;
  
  difference() {
    floor_2d();
    offset(-wall) floor_2d();
  }
}

module main() {  
  difference() {
    color("orange")
      linear_extrude(hole_depth)
        fence_2d();

    gridify()
      translate([0, 0, hole_depth - 0.8])
        cylinder(h=1.01, d1=hole_diam, d2=hole_diam+2);
  }
  
  floor_thickness = 1;
  translate([0, 0, -floor_thickness])
    linear_extrude(floor_thickness)
      floor_2d();
  
  wall_height = 45;
  translate([0, 0, -eps])
    linear_extrude(wall_height)
      wall_2d();
}

main();
