include <common.scad>
use <head.scad>

// Utilities for 1mm-deep graphic or text engravings. Note that
// dice.scad has its own engraving library for dice.

module engrave() {
  translate([0, 0, -1+eps])
    linear_extrude(1)
      children();
}

module mytext(s) {
  text(
    text=s,
    size=4,
    font="DejaVu Sans",
    halign="center",
    valign="center",
    spacing=1.1);
}

module magic_circle() {
  od = 10;
  difference() {
    circle(od/2);
    circle(od/2-0.5);
  }
}

module iron_bar() {
  polygon([
    [-4, 0],
    [-3.5, 2],
    [3.5, 2],
    [4, 0],
  ]);
}

module sword() {
  // Blade and hilt.
  polygon([
    [-0.5, -5.5],
    [0.5, -5.5],
    [0.5, 6],
    [0, 8],
    [-0.5, 6],
  ]);
  
  // Rounded pommel.
  translate([0, -5.5, 0]) circle(r=0.7);
  
  // Crossguard.
  polygon([
    [-2, -2],
    [-2, -3],
    [2, -3],
    [2, -2],
  ]);
  translate([2, -2.5, 0]) circle(r=0.5);
  translate([-2, -2.5, 0]) circle(r=0.5);
}

module iron_helm() {
  translate([0, 1.5-eps, 0])
    scale([1, 1.2, 1])
      iron_bar();
  
  // Cheek plates.
  intersection() {
    translate([0, -48.5, 0]) square(100, center=true);
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        translate([-2.4, 1, 0])
          rotate([0, 0, 90])
            scale([1, 0.8, 1])
              iron_bar();
        
        // Triangles that flare inwards at the bottom.
        polygon([
          [-2.4, -0.1],
          [-2.4, -3],
          [-1.4, -3],
        ]);
      }
    }
  }
  
  // Nose piece.
  translate([0, 1, 0]) square([1.2, 2], center=true);
}

module magic_helm() {
  difference() {
    circle(4);
    intersection() {
      circle(4-0.7);
      translate([0, 1, 0])
        square([10, 1.5], center=true);
    }
    translate([0, -3, 0])
      square([2, 8], center=true);
  }
}

// Demo
difference() {
  // The clear area in the middle of chip is about 9.6mm on a side.
  translate([0, 0, -3.5])
    heavy_weapon();
  
  engrave() {
    sword();
    magic_circle();
  }
}