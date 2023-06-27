include <common.scad>

side = 100;
engrave = 10;
engrave_offset = side/2-engrave+0.001;

difference() {
  translate([0, 0, -side/2])
    chamfered_box([side, side, side], chamfer=5);
  
  rotate([90, 0, 0]) 
    translate([-27, -30, engrave_offset])
      linear_extrude(engrave)
        offset(0.2)
          text("J", 70, "Bookman");

  // Question mark.
  rotate([180, 0, 0]) {
    translate([0, 0, engrave_offset]) {
      linear_extrude(engrave) {
        translate([0, -3, 0]) {
          polygon([
            [-7, -10],
            [-7, 0],
            [0, 8],
            [10, 8],
            [10, 18],
            [-10, 18],
            [-12, 16],
            [-12, 10],
            [-22, 10],
            [-22, 22],
            [-14, 30],
            [15, 30],
            [22, 22],
            [22, 6],
            [14, -2],
            [9, -2],
            [7, -4],
            [7, -10],
          ]);
          polygon([
            [-7, -26],
            [-7, -16],
            [7, -16],
            [7, -26],
          ]);
        }
    
        // Studs around question mark.
        for (a = [-1, 1], b = [-1, 1])
          scale([a, b, 1])
            translate([37, 37, 0])
              circle(5);
      }
    }
  }
}