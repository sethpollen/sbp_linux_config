use <figure_base.scad>;

// The internal dimensions of my tub are 150mm by 283mm.

eps = 0.00001;
$fn = 50;

wall = 6.4;
spacing_y = 53.2;

// TODO: Copied from rack.scad.
flange = 3.5;
hole_depth = 3.2;
floor_height = 1;
height = floor_height + hole_depth; 

module hole_2d() {
  offset(0.3) double_base_2d();
}

// `piece` should be 0 or 1.
module holes_2d(p=0, offs=0) {
  intersection() {
    square([153, 285], center=true);
    offset(offs)
      for (a = [-1, 1], y = [p*2 : 1 + p*3])
        scale([a, 1])
          translate([37, 106.5 - spacing_y*y])
            rotate([0, 0, -39])
              hole_2d();
  }
}

module piece_2d(p) {
  difference() {
    holes_2d(p=p, offs=wall);
    holes_2d(p=p);
    
    if (p == 1)
      piece_2d(0);
  }
}

module piece(p) {
  // TODO: 2 is just for testing. The real thing should be taller.
  height = 2;
  translate([0, 0, 0.2])
    linear_extrude(height-0.2)
      piece_2d(p);
  linear_extrude(0.2+eps)
    offset(-0.3)
      piece_2d(p);
}

module main() {
  piece(0);
  piece(1);
}

main();