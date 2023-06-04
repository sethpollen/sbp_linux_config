include <common.scad>
use <head.scad>

// Utilities for 1mm-deep graphic or text engravings. 
// Note that dice.scad has its own engraving library
// for dice.

// The clear area in the middle of chip is about 9.6mm 
// on a side.

module engrave() {
  translate([0, 0, -1+eps])
    linear_extrude(1)
      children();
}

module mytext_2(s) {
  text(
    text=s,
    size=4,
    font="DejaVu Sans",
    halign="center",
    valign="center",
    spacing=1.1);
}

module magic_circle_2() {
  od = 9;
  difference() {
    circle(od/2);
    circle(od/2-0.5);
  }
}

module sword_2(wide=false) {  
  // Blade and hilt.
  polygon([
    [0.5, -5.5],
    [0.5, 5.5],
    [0, 7.5],
    [-0.5, 5.5],
    [-0.5, -5.5],
  ]);
  
  // Rounded pommel.
  translate([0, -5.5, 0]) 
    circle(r = 0.7);
  
  // Crossguard.
  polygon([
    [-2, -2],
    [-2, -3],
    [2, -3],
    [2, -2],
  ]);
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([2, -2.5, 0])
        circle(r=0.5);
}

module helm_2(circ=false) {
  // Center the whole thing.
  translate([0, circ ? 0 : 0.25, 0]) {
    difference() {
      if (circ) {
        circle(4);
      } else {
        translate([0, -0.5, 0])
          square([8, 7], center=true);
      }
      intersection() {
        if (circ) {
          circle(3.3);
        } else {
          square(6.6, center=true);
        }
        translate([0, 1, 0])
          square([10, 1.5], center=true);
      }
      translate([0, -3, 0])
        square([2, 8], center=true);
    }
  }
}

module square_mail_2() {
  for (a = [-2, 0, 2], b = [-1, 1]) {
    translate(2*[a, b, 0]) {
      rotate([0, 0, 45]) {
        difference() {
          square(4, center=true);
          square(2.5, center=true);
        }
      }
    }
  }
}

module bricks_2() {
  translate([3.5, 0]) square([5, 1.5], center=true);
  translate([-3.5, 0]) square([5, 1.5], center=true);
  translate([0, 3]) square([5, 1.5], center=true);
  translate([0, -3]) square([5, 1.5], center=true);
}

module fire_2() {
  difference() {
    union() {
      circle(r=3);
      translate([0.3, 3, 0]) {
        circle(r=1);
        polygon([[-0.9, 0.4], [0.9, 0.4], [0, 3]]);
      }
    }
    // Cut-out flames.
    translate([-1, -0.5, 0]) {
      circle(r=1);
      polygon([[-0.9, 0.4], [0.9, 0.4], [0, 5]]);
    }
    translate([1.5, 0.5, 0]) {
      circle(r=1);
      polygon([[-0.9, 0.4], [0.9, 0.4], [0, 3]]);
    }
  }
  
  // A ring around everything.
  difference() {
    circle(4.5);
    circle(4);
    offset(0.7)
      translate([0.3, 3, 0])
        polygon([[-0.9, 0.4], [0.9, 0.4], [0, 3]]);
  }
}

module spiral() {
  translate([0, 7, 0])
  projection()
    rotate([45, 0, 0])
      rotate([0, 0, -20])
        linear_extrude(20, twist=4*360-40)
          translate([2.7, 0, 0])
            circle(0.4);
}
