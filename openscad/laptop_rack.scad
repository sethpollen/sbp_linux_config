$fa = 5;
$fs = 0.2;

donut_ir = 11;
donut_or = donut_ir+2;
donut_core_offset = 25;
donut_core_length = 30;

module donut() {
  for (a = [-1, 1], b = [-1, 1]) {
    scale([a, 1, b]) {
      linear_extrude(donut_core_length) {
        difference() {
          translate([0, -donut_or, 0])
            square([donut_or+donut_core_offset, donut_or*2]);
          translate([donut_core_offset, 0, 0])
            circle(donut_ir);
        }
      }
      translate([0, 0, donut_core_length]) {
        rotate([90, 0, 0]) {
          rotate_extrude(angle=90) {
            difference() {
              translate([0, -donut_or, 0])
                square([donut_core_offset*0.8, 2*donut_or]);
              translate([donut_core_offset, 0, 0])
                circle(donut_ir);
            }
          }
        }
      }
    }
  }
}

wall_thickness = 10;
wall_corner_radius = 20;

module wall_corner() {
  
}

wall_corner();
donut();