include <common.scad>
include <screw.scad>

retention_plate_thickness = 1.2;
retention_plate_width = washer_od;
retention_plate_clip_length = 9;

// Plate which covers the ends of the pins.
module retention_plate(length) {
  dims = [retention_plate_width, length, 2*retention_plate_thickness];

  difference() {
    // Chamfer only the bottom.
    intersection() {
      chamfered_cube(dims, 0.4);
      translate([0, 0, -retention_plate_thickness])
        cube(dims);
    }
    
    translate([retention_plate_width/2, length/2, -eps]) {
      linear_extrude(10)
        octagon(screw_hole_id);
      linear_extrude(0.2)
        octagon(screw_hole_id + 0.4);
    }
  }
}

module retention_plate_clips(plate_length) {
  clearance = extra_loose;
  height = retention_plate_thickness * 3 + clearance;

  difference() {
    translate([-height, 0, -height + retention_plate_thickness]) {
      intersection() {
        translate([0, -plate_length/2, 0])
          chamfered_cube([retention_plate_width + 2*height, plate_length*2, 2*height], height);
        for (y = [0, plate_length - retention_plate_clip_length])
          translate([0, y, -height])
            cube([retention_plate_width + 2*height, retention_plate_clip_length, 2*height]);
      }      
    }
    
    // Cavity for the plate.
    translate([-clearance/2, -eps, -clearance + eps])
      cube([
        retention_plate_width + clearance,
        plate_length + 2*eps,
        retention_plate_thickness + clearance
      ]);
    
    // Pin holes.
    for (y = [0, plate_length - retention_plate_clip_length])
      translate([retention_plate_width/2, retention_plate_clip_length/2 + y, -5])
        linear_extrude(10)
          octagon(nail_loose_diameter);
  }
}

module retention_nut_hole(plate_length) {
  translate([retention_plate_width/2, plate_length/2, retention_plate_thickness-eps]) {
    rotate([0, 0, 90]) {
      nut_cavity();
      linear_extrude(10)
        octagon(screw_hole_id);
    }
  }
}
