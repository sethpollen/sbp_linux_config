disk_d = 25;
disk_h = 7.2;
roundoff_r = 2;
cutoff = 3.7;

module stone_2d() {
  $fn = 30;
  hull() {
    for (a = [-1, 1])
      translate([disk_d/2 - roundoff_r, a * (disk_h/2 - roundoff_r)])
        circle(roundoff_r);
    translate([1, 0])
      square([2, disk_h], center=true);
  }
}

module stone() {
  $fn = 110;
  intersection() {
    rotate([90, 0, 0])
      rotate_extrude(angle=360)
        stone_2d();
    translate([0, 0, cutoff])
      cube(disk_d, center=true);
  }
}

module capstone() {
  $fn = 110;
  scale(0.8) {
    intersection() {
      sphere(disk_d/2);
      translate([0, 0, cutoff])
        cube(disk_d, center=true);
    }
  }
}

module dense_fill() {
  cube([150, 150, disk_d*0.19]);
}

stone();