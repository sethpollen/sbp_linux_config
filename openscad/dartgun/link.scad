include <common.scad>

pin_diameter = 3.175;
pin_hole_diameter = pin_diameter + loose;

main_diameter = 12;
thickness = 10;
height = 13;

module front_link_2d(length) {
  difference() {
    union() {
      hull() {
        circle(d=main_diameter);
        translate([0, length])
          circle(d=main_diameter);
      }
      hull() {
        circle(d=main_diameter);
        translate([height, 0])
          octagon(main_diameter);
      }
    }
    
    for (xy = [[height, 0], [0, length]])
      translate(xy)
        octagon(pin_hole_diameter);
  }
}

module front_link(length) {
  rotate([0, -90, 0])
    linear_extrude(thickness)
      front_link_2d(length);
}

module rear_link_a_2d(length) {
  difference() {
    union() {
      hull() {
        translate([0, main_diameter])
          octagon(main_diameter);
        translate([0, length])
          circle(d=main_diameter);
      }

    }
    translate([0, length])
      octagon(pin_hole_diameter);
  }
}

module rear_link_b_2d() {
  difference() {
    hull() {
      octagon(main_diameter);    
      translate([height, 0])
        octagon(main_diameter);    
      translate([0, main_diameter*2])
        octagon(main_diameter);    
    }
    translate([height, 0])
      octagon(pin_hole_diameter);
  }
}

module rear_link(length) {  
  rotate([0, -90, 0]) {
    linear_extrude(thickness)
      rear_link_a_2d(length);
    
    for (z = [-thickness/2, thickness + loose/2])
      translate([0, 0, z])
        linear_extrude(thickness/2 - loose/2)
          rear_link_b_2d();
    
    for (z = [-loose/2, thickness]) {
      translate([0, 0, z]) {
        linear_extrude(loose/2) {
          intersection() {
            rear_link_a_2d(length);
            rear_link_b_2d();
          }
        }
      }
    }
  }
}

module link_pair(stroke) {
  // Avoid over-angling.
  min_separation = 4 * main_diameter;
  max_separation = min_separation + stroke;
  link_length = max_separation / 2;

  translate([thickness, 0, 0])  
    rear_link(link_length);
  translate([-thickness, 0, 0])  
    front_link(link_length);
}

module link_anchor_2d() {
  difference() {
    hull() {
      translate([height, 0])
        octagon(main_diameter);
      square([main_diameter, main_diameter*2], center=true);
    }
    translate([height, 0])
      octagon(pin_hole_diameter);
  }
}

module link_anchor() {
  translate([-thickness/2, 0, -main_diameter/2]) {
    rotate([0, 90, 0]) {
      for (z = [-thickness/2, thickness + loose/2])
        translate([0, 0, z])
          linear_extrude(thickness/2 - loose/2)
            link_anchor_2d();
      translate([0, 0, -thickness/2])
        linear_extrude(thickness*2)
          square([main_diameter, main_diameter*2], center=true);
    }
  }
}
