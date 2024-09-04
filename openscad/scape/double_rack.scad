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
    // Inner dimensions of the container.
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

module flange_2d(p) {
  difference() {
    holes_2d(p=p, offs=1);
    holes_2d(p=p, offs=-flange);
  }
}

module piece(p) {
  difference() {
    union() {
      translate([0, 0, 0.2]) {
        linear_extrude(height-0.2)
          piece_2d(p);
        linear_extrude(floor_height-0.2)
          flange_2d(p);
      }
      linear_extrude(0.2+eps) {
        offset(-0.3) {
          piece_2d(p);
          flange_2d(p);
        }
      }
    }
    
    for (a = [1:3])
      translate([0, 0, height-0.8+a*0.2])
        linear_extrude(1)
          holes_2d(p=p, offs=a*0.2);
  }
}

module main() {
  piece(1);
}

main();