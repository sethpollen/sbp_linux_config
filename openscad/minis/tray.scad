include <common.scad>

difference() {
  union() {
    // Exterior.
    hull()
      for (a = [-1, 1], b = [-1, 1])
        translate([68*a, 68*b, 0])
          chamfered_disk(75, 25);
      
    // Crenellations.
    for (a = [0, 90, 180, 270]) {
      rotate([0, 0, a]) {
        translate([88, 0, 65.7]) {
          intersection() {
            cube([21.8, 100, 100], center=true);
            rotate([0, 45, 0]) {
              chamfered_box([7, 40, 30], chamfer=1.1);
            }
          }
          translate([8.75, 0, 6])
            chamfered_box([6.5, 40, 12], chamfer=1.1);
        }
      }
    }
  }

  // Main interior volume.
  hull()
    for (a = [-1, 1], b = [-1, 1])
      translate([67*a, 67*b, 50])
        cylinder(80, r=22, center=true);
    
  // Chamfer on inner top edge.
  hull()
    for (a = [-1, 1], b = [-1, 1])
      translate([67*a, 67*b, 73.9])
        chamfered_disk(100, 23);

  // Sockets.
  translate([-67.5, -67.5, 3]) {
    repeatx(4, 45) {
      repeaty(4, 45) {
        chamfered_disk(10, 20.5);
        translate([0, 0, 6])
          chamfered_disk(10, 21.5);
      }
    }
  }
}
