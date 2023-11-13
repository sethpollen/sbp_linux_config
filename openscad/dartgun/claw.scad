// Retention claw for 1/8" steel pins.

include <common.scad>

pin_diameter = 3.175;
pinch = 0.5;
pin_cavity_width = pin_diameter - pinch;

pillar_thickness = 2;
spring_thickness = 1;
exterior_width = 2*spring_thickness + pin_cavity_width;

pillar_length = 2.5;
spring_length = 10;
exterior_length = 2*pillar_length + spring_length;

pin_cavity_height = 4;
separation = 0.4;
plate_height = 2;
exterior_height = pin_cavity_height + 2*separation + plate_height;

module claw() {
  difference() {
    translate([-exterior_width/2, -exterior_length/2, 0])
      cube([exterior_width, exterior_length, exterior_height]);
    
    // Central cavity.
    translate([-pin_cavity_width/2, -spring_length/2, -eps])
      cube([pin_cavity_width, spring_length, exterior_height - plate_height]);
    
    // Separations around the spring.
    for (z = [0, pin_cavity_height + separation])
      translate([-exterior_width/2 - 1, -spring_length/2, z-eps])
        cube([exterior_width + 2, spring_length, separation]);
    
    // Bevels to admit the pin.
    rotate([0, 45, 0]) {
      cube([
        (exterior_width+spring_thickness)/sqrt(2),
        spring_length,
        (exterior_width+spring_thickness)/sqrt(2)
      ], center=true);
    }
  }
}

module claw_print() {
  rotate([90, 0, 0])
    claw();
}

claw_print();