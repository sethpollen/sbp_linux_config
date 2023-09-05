// Results:
//
// Unfortunately the X-SHOT darts are wider than the NERF darts.
// A good compromise is 13.1mm for the driving band. This is wide
// enough to allow X-SHOT darts to pass while narrow enough to
// still gently grip a NERF dart.
//
// 13.7mm seems sufficiently wide to allow an X-SHOT dart to drop
// through, but it might be best to add a bit more room and do 13.8mm.

include <common.scad>

$fa = 5;
$fs = 0.2;
h = 20;

module bt(id) {
  difference() {
    linear_extrude(h) {
      difference() {
        circle(d=id+2.4);
        circle(d=id);
      }
    }
    
    translate([0, 0, -eps])
      linear_extrude(foot, scale=(id+foot)/id)
        circle(d = id+foot);
  }
  
  translate([id/2, 0, h]) {
    difference() {
      translate([0.9, 0, -h/2])
        cube([1.8, 8, h], center=true);
      
      translate([0.601, -3, -1])
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