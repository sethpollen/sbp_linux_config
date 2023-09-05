include <common.scad>

$fa = 5;
$fs = 0.2;
h = 20;

module bt(id) {
  linear_extrude(h) {
    difference() {
      circle(d=id+3.2);
      circle(d=id);
    }
  }
  
  translate([id/2, 0, h]) {
    difference() {
      translate([1, 0, -h/2])
        cube([2, 8, h], center=true);
      
      translate([0.801, -3, -1])
        rotate([0, 90, 0])
          linear_extrude(1.2)
            offset(0.2)
              text(str(id), 6);
    }
  }
}

for (a = [0, 1, 2, 3])
  translate([0, a * 18, 0])
    bt(dart_diameter+a*0.1);
for (a = [4, 6, 8, 10])
  translate([18, a * 9 - 36, 0])
    bt(dart_diameter+a*0.1);