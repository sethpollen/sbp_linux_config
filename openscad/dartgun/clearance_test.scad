include <common.scad>

hole_diameter = 5;
hole_wall = 5;
hole_height = 10;
hole_side = hole_diameter + 2*hole_wall;

module hole() {
  difference() {
    flare_cube([hole_side, hole_side, hole_height], foot);
    translate([hole_side/2, hole_side/2, -eps])
      flare_cylinder(100, hole_diameter/2, -foot);
  }
}

module pin(clearance) {
  difference() {
    union() {
      flare_cube([hole_side, hole_side, 3], foot);
      translate([hole_side/2, hole_side/2, 0])
        cylinder(hole_height+2, d=hole_diameter-clearance);
    }
    
    translate([11, 3, -eps])
      scale([-1, 1, 1])
        linear_extrude(1)
          text(str(clearance*10));
  }
}

for (n = [0.0, 0.1, 0.2, 0.3])
  translate([n*170, 0, 0])
    pin(n);
for (n = [0.4, 0.5, 0.6, 0.7, 0.8])
  translate([(n-0.4)*170, 17, 0])
    pin(n);
translate([68, 0, 0])
  hole();