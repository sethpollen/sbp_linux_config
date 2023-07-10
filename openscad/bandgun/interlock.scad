include <common.scad>

// TODO: clean this up.

module socket() {
  intersection() {
    translate([-4, 0, 0])
      square([11, 4]);
    
    difference() {
      union() {
        rotate([0, 0, -45])
          translate([0, 6, 0])
            circle(3);
        rotate([0, 0, 45])
          square(8);
        translate([-4, 1])
          square(8, center=true);
      }
      circle(3);
    }
  }
}

module ball() {
  circle(2.95);
}

module fork1() {
  difference() {
    union() {
      difference() {
        translate([0, 0, 0]) cube([30, 60, 11], center=true);
        translate([0, 9, 0]) cube([18, 60, 12], center=true);
      }
      for (x = [-9, 9])
        translate([x, 4.5, 0])
          square_rail(51+eps);
    }
    for (x = [-15, 15])
      translate([x, 0, 0])
        round_rail(1000);
  }
  
  translate([-2.5, -17-eps, -1.5])
    rotate([180, -90, 0])
      linear_extrude(5)
        socket();
}

module fork2() {
  difference() {
    cube([17.6, 100, 11], center=true);
    translate([0, -8, 0]) cube([6, 100, 12], center=true);
    for (x = [-8.8, 8.8])
      translate([x, 0, 0])
        square_rail(1000);
    translate([0, 50, 0])
      rotate([0, 0, 90])
        round_rail(1000);
  }

  translate([3.5, 38+eps, -1.5])
    rotate([0, -90, 0])
      linear_extrude(7)
        socket();
}

module insert() {
  length = 84;
  translate([2.5, -4, -2.55]) {
    rotate([0, -90, 0]) {
      linear_extrude(5) {
        translate([0, -15, 0])
          square([35, 30]);
        hull()
          for (y = length/2 * [-1, 1])
            translate([0, y, 0])
              ball();
      }
    }
  }
}

module test() {
  translate([0, -29.2, 0]) fork1();
  fork2();
  translate([0, 0, 1.05]) insert();
}

module profile() {
  projection(cut=true)
    rotate([0, 90, 0])
      test();
}

module print() {
  translate([30, 0, 0]) fork1();
  translate([-30, 0, 0]) fork2();
  insert();
}

print();

