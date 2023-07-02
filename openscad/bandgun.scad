$fa = 6;
$fs = 0.5;
eps = 0.000001;

module pyramid(radius, height) {
  linear_extrude(height, scale=0)
    rotate([0, 0, 45])
      square(radius*sqrt(2), center=true);
}

module octahedron(radius) {
  for (a = [-1, 1])
    scale([1, 1, a])
      pyramid(radius, radius);
}

module round_rect(dims, radius) {
  hull()
    for (a = [-1, 1], b = [-1, 1])
      translate([
        (dims.x*0.5-radius)*a,
        (dims.y*0.5-radius)*b,
        0
      ])
        circle(radius);
}

grip_height = 80;

module grip() {
  angle = 18;
  radius = 12;
  length = 55;
  width = 28;
  cross_length = length*sin(90 - angle);

  intersection() {
    // A tilted solid for the grip.
    translate([-(100+grip_height)*tan(angle), 0, -100])
      rotate([0, angle, 0])
        linear_extrude(1000)
          round_rect([cross_length, width], radius);

    // Trim it to the desired height.
    translate([-500, -500, 0])
      cube([1000, 1000, grip_height]);
  }
}

module receiver() {
  translate([-28, 0, 15+grip_height-eps]) {
    difference() {
      union() {
        // Receiver exterior.
        rotate([0, 90, 0])
          linear_extrude(130)
            round_rect([30, 22], 3);
        
        // Grip fillet.
        translate([28, 0, -15])
          linear_extrude(5, scale=[1, 0.7])
            projection(cut=true)
              translate([0, 0, -grip_height])
                grip();
      }
      
      // Cutout for the sliding action.
      translate([0, 0, 500-8])
        cube([1000, 8, 1000], center=true);
      
      // Cutout for the trigger.
      translate([60, 0, 0])
        cube([60, 8, 1000], center=true);
      
      // Slant the back of the slide.
      // TODO:
    }
  }
}

grip();
receiver();