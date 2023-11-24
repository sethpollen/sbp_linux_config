include <common.scad>

pin_diameter = 3.175;
pin_hole_diameter = pin_diameter + loose;

main_diameter = 12;
link_thickness = 10;
link_height = 13;

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
        translate([link_height, 0])
          octagon(main_diameter);
      }
    }
    
    for (xy = [[link_height, 0], [0, length]])
      translate(xy)
        octagon(pin_hole_diameter);
  }
}

module front_link(length) {
  rotate([0, -90, 0])
    linear_extrude(link_thickness)
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
      translate([link_height, 0])
        octagon(main_diameter);    
      translate([0, main_diameter*2])
        octagon(main_diameter);    
    }
    translate([link_height, 0])
      octagon(pin_hole_diameter);
  }
}

module rear_link(length) {  
  rotate([0, -90, 0]) {
    linear_extrude(link_thickness)
      rear_link_a_2d(length);
    
    for (z = [-link_thickness/2, link_thickness + loose/2])
      translate([0, 0, z])
        linear_extrude(link_thickness/2 - loose/2)
          rear_link_b_2d();
    
    for (z = [-loose/2, link_thickness]) {
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

  translate([link_thickness, 0, 0])  
    rear_link(link_length);
  translate([-link_thickness, 0, 0])  
    front_link(link_length);
}

module link_anchor_2d(hole = true) {
  difference() {
    hull() {
      translate([link_height, 0])
        circle(d=main_diameter);
      translate([-main_diameter/2, 0])
        square([eps, main_diameter*3], center=true);
    }
    if (hole)
      translate([link_height, 0])
        octagon(pin_hole_diameter);
  }
}

module link_anchor(enclosure_thickness = 0) {
  // Extra play on either end of the pin, in case it is enclosed.
  play = 1;
  width = link_thickness*2 + 2*play;

  translate([-link_thickness, 0, -main_diameter/2]) {
    rotate([0, 90, 0]) {
      difference() {
        linear_extrude(width)
          link_anchor_2d();
        translate([main_diameter/2, -25, link_thickness/2 + loose/2 + play])
          cube([50, 50, link_thickness - loose]);
      }
      
      if (enclosure_thickness > 0) {
        // Put plates on both ends of the pin.
        for (z = [-enclosure_thickness, width])
          translate([0, 0, z])
            linear_extrude(enclosure_thickness)
              link_anchor_2d(hole=false);
      }
    }
  }
}
