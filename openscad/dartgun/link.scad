include <barrel2.scad>
include <common.scad>

pin_diameter = 3.175;
pin_hole_diameter = pin_diameter + loose;

main_diameter = 13;
link_thickness = 12;
link_height = 14;

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

module link_anchor_2d(hole = true, spread) {
  difference() {
    hull() {
      translate([link_height - slider_wall, 0])
        circle(d=main_diameter);
      translate([-main_diameter/2, -main_diameter/2])
        square([eps, main_diameter * (1 + spread)]);
    }
    if (hole)
      translate([link_height - slider_wall, 0])
        octagon(pin_hole_diameter);
  }
}

link_anchor_play = 1.5;
link_anchor_thickness = link_thickness + link_anchor_play;

module link_anchor(spread = 1) {
  translate([main_diameter/2, 0, 0]) {
    difference() {
      linear_extrude(link_anchor_thickness)
        link_anchor_2d(spread=spread);
      translate([main_diameter/2 - slider_wall, -15, link_thickness/2 + loose/2 + link_anchor_play])
        cube([40, 40, link_thickness - loose]);
    }
    
    wall = slider_width/2 - link_anchor_thickness;
    translate([0, 0, -wall])
      linear_extrude(wall)
        link_anchor_2d(hole=false, spread=spread);
  }
}
