loose = 0.2;
$fa = 5;
$fs = 0.2;

// Menards 5/8 x 2-3/4 x 0.04 WG compression spring.
spring_od = 5/8 * 25.4;
// Relaxed length.
spring_max_length = 2.75 * 25.4;
spring_min_length = 16;  // Approximate.

tube_wall = 2;
axle_diameter = 5;

// 550 paracord.
string_diameter = 3;

wheel_diameter = axle_diameter + 2*spring_od + 4*tube_wall;
wheel_thickness = string_diameter + 2;

module wheel() {
  difference() {
    square([wheel_diameter/2, wheel_thickness]);
    translate([wheel_diameter/2, wheel_thickness/2])
      circle(d=string_diameter);
  }
}

wheel();