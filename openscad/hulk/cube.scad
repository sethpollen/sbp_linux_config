eps = 0.0001;
$fn = 20;

cube_side = 19;
chamfer = 2;
engrave = 3;
recess_depth = 1.8;

module cube() {
  hull()
    for (a = [-1, 1], b = [-1, 1], c = [-1, 1])
      scale([a, b, c])
        translate((cube_side/2 - chamfer) * [1, 1, 1])
          sphere(chamfer);
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
  // Blade and hilt.
  polygon([
    [1, -2],
    [1, 5.5],
    [0, 7.5],
    [-1, 5.5],
    [-1, -2],
  ]);
  
  // Crossguard.
  polygon([
    [-2, -0.5],
    [-2, -2],
    [2, -2],
    [2, -0.5],
  ]);
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([2, -1.25, 0])
        circle(r=0.75);
  
  // Scalloped grip.
  for (y = [0.4, 1.6, 2.8])
    translate([0, -y-2.4])
      square([2, 0.8], center=true);
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
  
  translate([0, -3])
    rotate([0, 0, 90])
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

module recess() {
  hull()
    for (a = [-1, 1], b = [-1, 1])
      scale([a, b, 1])
        translate((cube_side/2 - chamfer - recess_depth) * [1, 1, 0])
          sphere(recess_depth);
}

module preview() {
  difference() {
    cube();
    
    translate([0, 0, cube_side/2 - engrave - recess_depth])
      linear_extrude(10)
        bullet_saw_2d();
    
    rotate([0, -90, 0])
      translate([0, 0, cube_side/2 - engrave])
        linear_extrude(10)
          bullet_saw_2d();
    
    translate([0, 0, cube_side/2])
      recess();
  }
}

preview();