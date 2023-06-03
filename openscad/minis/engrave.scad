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

module iron_bar_2() {
  polygon([
    [-4, 0],
    [-3.5, 2],
    [3.5, 2],
    [4, 0],
  ]);
}

module sword_2(wide=false) {  
  // Blade and hilt.
  blade_x = wide ? 1 : 0.5;
  polygon([
    [blade_x, -5.5],
    [blade_x, 5.5],
    [0, 7.5],
    [-blade_x, 5.5],
    [-blade_x, -5.5],
    // Trapezoid pommel.
    [-blade_x*0.6, -6],
    [blade_x*0.6, -6],
  ]);
  
  // Rounded pommel.
  if (!wide) {
    translate([0, -5.5, 0]) 
      circle(r = 0.7);
  }
  
  // Crossguard.
  if (wide) {
    polygon([
      [-2.5, -1.2],
      [-2.5, -2.5],
      [-2, -3],
      [2, -3],
      [2.5, -2.5],
      [2.5, -1.2],
    ]);
  } else {
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
}

module iron_helm_2() {
  translate([0, 1.5-eps, 0])
    scale([1, 1.2, 1])
      iron_bar_2();
  
  // Cheek plates.
  intersection() {
    translate([0, -48.5, 0]) square(100, center=true);
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        translate([-2.4, 1, 0])
          rotate([0, 0, 90])
            scale([1, 0.8, 1])
              iron_bar_2();
        
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

module magic_helm_2() {
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
  translate([3.5, 0]) square([5, 2], center=true);
  translate([-3.5, 0]) square([5, 2], center=true);
  translate([0, 3.1]) square([5, 2], center=true);
  translate([0, -3.1]) square([5, 2], center=true);
}

// TODO:
bricks_2();

