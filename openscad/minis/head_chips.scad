include <common.scad>
use <head.scad>

// Utilities for 1mm-deep graphic or text engravings. 
// Note that dice.scad has its own engraving library
// for dice.

// The clear area in the middle of chip is about 9.6mm 
// on a side.

module sword_2(circ=false) {  
  // Blade and hilt.
  polygon([
    [0.5, -5.5],
    [0.5, 5.5],
    [0, 7.5],
    [-0.5, 5.5],
    [-0.5, -5.5],
  ]);
  
  if (circ) {
    // Rounded pommel.
    translate([0, -5.5, 0]) 
      circle(r = 0.7);
  } else {
    // Square pommel.
    translate([0, -5.5, 0]) 
      rotate([0, 0, 45])
        square(1.3, center=true);
  }
  
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
  
  if (circ) {
    // A magic circle around the sword.
    difference() {
      circle(4.5);
      circle(4);
    }
  }
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

// First child is the chip. Remaining children are
// the 2-D engravings.
module engrave_chip() {
  if ($flat) {
    children([1:$children-1]);
  } else {
    difference() {
      children(0);
      if ($children > 1)
        translate([0, 0, 2.5+eps])
          linear_extrude(1)
            children([1:$children-1]);
    }
  }
}

module magic_sword() {
  engrave_chip() {
    heavy_weapon();
    sword_2(circ=true);
  }
}

module iron_sword() {
  engrave_chip() {
    light_weapon();
    sword_2();
  }
}

module magic_helm() {
  engrave_chip() {
    heavy_armor();
    helm_2(circ=true);
  }
}

module iron_helm() {
  engrave_chip() {
    light_armor();
    helm_2(circ=false);
  }
}

module iron_mail() {
  engrave_chip() {
    light_armor();

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
}

module wall() {
  engrave_chip() {
    heavy_armor();

    translate([3.5, 0]) square([5, 1.5], center=true);
    translate([-3.5, 0]) square([5, 1.5], center=true);
    translate([0, 3]) square([5, 1.5], center=true);
    translate([0, -3]) square([5, 1.5], center=true);
  }
}

module fire() {
  engrave_chip() {
    heavy_armor();

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
}

module jump_back() {
  engrave_chip() {
    light_armor();

    translate([0, 7, 0])
      projection()
        rotate([45, 0, 0])
          rotate([0, 0, -20])
            linear_extrude(20, twist=4*360-40)
              translate([2.7, 0, 0])
                circle(0.4);
  }
}

module ender_pearl() {
  engrave_chip() {
    heavy_armor();
    
    difference() {
      circle(4.5);
      circle(4);
    }
    scale([1.1, 0.6, 1]) {
      difference() {
        circle(3);
        circle(2.2);
      }
    }
  }
}

// Weapons.
translate([0, 0, 0]) magic_sword();
translate([0, 25, 0]) iron_sword();

// Armor.
translate([25, 0, 0]) magic_helm();
translate([25, 25, 0]) iron_helm();
translate([-25, 0, 0]) iron_mail();
translate([-25, 25, 0]) wall();
translate([25, -25, 0]) fire();
translate([0, -25, 0]) jump_back();
translate([-25, -25, 0]) ender_pearl();

// If true, we'll render just the 2D symbols. This is
// useful for producing a PNG to print in the guide.
$flat = false;