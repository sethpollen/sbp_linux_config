eps = 0.0001;
$fn = 20;

cube_side = 18;
chamfer = 2;
recess_depth = 1.8;

module blank_die() {
  difference() {
    hull()
      for (a = [-1, 1], b = [-1, 1], c = [-1, 1])
        scale([a, b, c])
          translate((cube_side/2 - chamfer) * [1, 1, 1])
            sphere(chamfer);
      
    // Chop off the bottom layer. We'll add a trimmed version below to counter
    // elephant foot.
    translate([0, 0, -cube_side/2])
      cube([100, 100, 0.4], center=true);
  }
  
  translate([0, 0, -cube_side/2])
    linear_extrude(0.2)
      offset(0.2)
        square([cube_side-2*chamfer, cube_side-2*chamfer], center=true);
}

module bullet_2d() {
  width = 3;
  length = 9.5;
  gap = 0.8;
  
  translate([3 - length/2, 0]) {
    scale([2, 1]) {
      intersection() {
        circle(d=width);
        translate([-width/2, 0])
          square(width, center=true);
      }
    }
    
    translate([gap, -width/2])
      square([length - width - gap, width]);
  }
}

module sword_2d() {
  translate([0.3, 0]) {
    rotate([0, 0, 90]) {
      // Blade.
      polygon([
        [1, -2],
        [1, 4.5],
        [0, 6],
        [-1, 4.5],
        [-1, -2],
      ]);
      
      // Crossguard.
      hull()
        for (a = [-1, 1])
          scale([a, 1, 1])
            translate([1.5, -1.25, 0])
              circle(r=0.75);
      
      // Scalloped grip.
      for (y = [0.4, 1.6, 2.8])
        translate([0, -y-2.4])
          square([2, 0.8], center=true);
    }
  }
}

module tooth_2d() {
  size = 3;
  
  translate([-1, 0]) {
    intersection() {
      polygon([
        [0, 0],
        [size, 0],
        [0, size],
      ]);
      
      square([2, size]);
    }
  }
}

module saw_2d() {
  circle(d=3);
  translate([0, -1.5])
    square([7, 3]);
  
  for (x = [0, 3, 6])
    translate([x, 2.2])
      tooth_2d();
  
  for (a = [60, 120])
    rotate([0, 0, a])
      translate([0, 2.2])
        tooth_2d();
}

module multi_bullet_2d() {
  translate([-1, 0])
    bullet_2d();
  translate([1, 4])
    bullet_2d();
  translate([1, -4])
    bullet_2d();
}

module bullet_sword_2d() {
  translate([0, 3])
    bullet_2d();
  
  translate([0, -2])
    sword_2d();
}

module bullet_saw_2d() {
  translate([0, 4.5])
    bullet_2d();
  
  translate([-1, -3.2])
    saw_2d();
}

module flame_2d() {
  translate([1.8, 0]) {
    scale([1.5, 1.5]) {
      rotate([0, 0, 90]) {
        difference() {
          union() {
            circle(r=3, $fn=30);
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
      }
    }
  }
}

module hammer_2d() {
  translate([2.8, 0])
    square([7, 2], center=true);
  translate([-3.5, 0])
    square([4, 8], center=true);
}

module bullet_axe_2d() {
  translate([0, 4.5])
    bullet_2d();
  
  // TODO: axe
}

module fist_2d() { 
  translate([-2.7, -3.5]) {
    for (a = [0:3])
      translate([0, 1.8*a])
        square([2.2, 1]);
    translate([2.8, 0])
      square([3, 6.4]);
    translate([2, 7.1])
      square([3, 1]);
  }
}

module square_recess() {
  hull()
    for (a = [-1, 1], b = [-1, 1])
      scale([a, b, 1])
        translate((cube_side/2 - chamfer - recess_depth) * [1, 1, 0])
          sphere(recess_depth);
}

module circular_recess() {
  difference() {
    rotate_extrude($fn=32) {
      hull() {
        translate([0, -recess_depth])
          square(2*recess_depth);
        translate([cube_side/2 - chamfer - recess_depth, 0])
          circle(recess_depth);
      }
    }
    
    // Crosshair notches.
    for (a = [0, 90, 180, 270])
      rotate([-30, 0, a+45])
        translate([0, 3.2 + cube_side/2 - chamfer, 0])
          cube([1.4, 10, 10], center=true);
  }
}

module engrave() {
  straight_depth = 2.5;
  translate([0, 0, -straight_depth])
    linear_extrude(10)
      children();
  for (a = [0: 5])
    translate([0, 0, -straight_depth-a*0.2])
      linear_extrude(10)
        offset(-a*0.2)
          children();
}

// Children:
//   0. Full weapon set.
//   1. Overwatch weapon.
//   2. Guard weapon.
module die() {
  difference() {
    blank_die();
    
    // Top: Exhausted face with square recess.
    translate([0, 0, cube_side/2]) {
      square_recess();
      translate([0, 0, -recess_depth])
        engrave()
          children(0);
    }

    // Front: Primary face with no recess.
    rotate([0, -90, 0])
      translate([0, 0, cube_side/2])
        engrave()
          children(0);
    
    // Side: Overwatch with round recess.
    if ($children >= 2) {
      rotate([0, -90, 90]) {
        translate([0, 0, cube_side/2]) {
          circular_recess();
          translate([0, 0, -recess_depth])
            engrave()
              children(1);
        }
      }
    }
    
    // Side: Guard with round recess.
    if ($children >= 3) {
      rotate([0, -90, -90]) {
        translate([0, 0, cube_side/2]) {
          circular_recess();
          translate([0, 0, -recess_depth])
            engrave()
              children(2);
        }
      }
    }
  }
}

module marine() {
  die() {
    bullet_2d();
    bullet_2d();
    fist_2d();
  }
}

module lorenzo() {
  die() {
    bullet_sword_2d();
    bullet_2d();
    sword_2d();
  }
}

module valencio() {
  die() {
    bullet_saw_2d();
    bullet_2d();
    fist_2d();
  }
}

lorenzo();