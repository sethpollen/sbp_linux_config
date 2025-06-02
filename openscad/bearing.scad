step = 3.5;
gap = 0.25;
balance = 0.65;
support_height = step*2;
ceiling_clearance = 0.6;
top_plate_thickness = 4;
bottom_plate_thickness = 1.6;

module sawtooth_2d() {
  translate([-step/2-gap/2, 0]) {
    intersection() {
      square(2000);
      for (i = [0:20])
        translate([-step, i*step*2])
          rotate([0, 0, 45])
            square(step*2*sqrt(2), center=true);
    }
    translate([-500, 0]) square([500, step*41]);
  }
}

module inner_2d(h, r) {
  intersection() {
    square([1000, h]);
    translate([r*balance-gap/2, 0]) sawtooth_2d();
    square([r, h-ceiling_clearance]);
  }
  translate([0, -bottom_plate_thickness+0.0001]) square([r, bottom_plate_thickness]);
  square([r*balance+step/2-gap, step*2]);
}

module outer_2d(h, r) {
  difference() {
    square([r, h]);
    translate([r*balance+gap/2, 0]) sawtooth_2d();
    translate([0, -1]) square([r+1, support_height+1]);
  }
  translate([0, h-0.0001]) square([r, top_plate_thickness]);
}

module bearing(h, r) {
  pretend_h = h - top_plate_thickness - bottom_plate_thickness;
  translate([0, 0, bottom_plate_thickness]) {
    rotate_extrude($fn=180) {
      inner_2d(pretend_h, r);
      outer_2d(pretend_h, r);
    }
  }
}

bearing(17, 13);
