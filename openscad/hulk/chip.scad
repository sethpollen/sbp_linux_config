layer = 0.2;
eps = 0.001;
chip_height = 5;

// Child is the 2d shape.
module blank_chip(height, chamfer=1) {
  // Bottom 2 layers: Extra chamfer for elephant foot.
  linear_extrude(layer)
    offset(-chamfer - 0.5*layer)
      children();
  translate([0, 0, layer])
    linear_extrude(layer)
      offset(-chamfer + 1.5*layer)
        children();

  for (z = [2*layer : layer : chamfer - layer])
    translate([0, 0, z])
      linear_extrude(layer)
        offset(-chamfer + layer + z)
          children();

  translate([0, 0, chamfer])
    linear_extrude(height - 2*chamfer)
      children();

  for (z = [0 : layer : chamfer - layer])
    translate([0, 0, height - chamfer + z])
      linear_extrude(layer)
        offset(-z)
          children();
}

module blip(count) {
  height = chip_height;
  
  difference() {
    blank_chip(height, 1.6)
      circle(d=24, $fn=80);
    
    translate([0, 0, -eps])
      for (a = (count == 1) ? [0] : (count == 2) ? [-0.5, 0.5] : [-1, 0, 1])
        translate([0, 4*a])
          linear_extrude(height-1.6, scale=0.5)
            square([10, 2.4], center=true);
  }
}

module command_points(value) {
  height = chip_height;
  
  difference() {
    blank_chip(height, 1.6)
      circle(d=24, $fn=80);
    
    translate([0, 0, -3*eps], $fn = 40)
      linear_extrude(height-1.6, scale=0.8)
        translate([5, -5.2, 0])
          scale([-1, 1, 1])
            offset(0.3)
              text(str(value), size = 12);
  }
}

module bullet_2d() {
  width = 3;
  length = 9;
  gap = 0.8;
  $fn = 30;
  
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

module fist_2d() { 
  translate([-2.8, -3.2]) {
    for (a = [0:3])
      translate([0, 1.8*a])
        square([2.2, 1]);
    translate([2.8, 0])
      square([3, 6.4]);
    translate([2, 7.1])
      square([3, 1]);
  }
}

module circular_recess(diameter) {
  recess_depth = 1.4;
  
  difference() {
    rotate_extrude($fn=32) {
      hull() {
        translate([0, -recess_depth])
          square(2*recess_depth);
        translate([diameter - recess_depth, 0])
          circle(recess_depth);
      }
    }
    
    // Crosshair notches.
    for (a = [0, 90, 180, 270])
      rotate([-30, 0, a+45])
        translate([0, 3.2 + diameter, 0])
          cube([1.8, 10, 10], center=true);
  }
}

module status_chip() {
  height = chip_height;
  
  difference() {
    blank_chip(height, 1)
      circle(d=16, $fn=80);

    translate([0, 0, height])
      circular_recess(6.4);
    
    for (a = [0:4])
      translate([0, 0, 1.8 - a*0.2])
        linear_extrude(height)
          offset(-a*0.2)
            children();
  }
}

module overwatch() {
  status_chip()
    bullet_2d();
}

module guard() {
  status_chip()
    fist_2d();
}

for (a = [0:2], b = [0:2])
  translate([a*18, b*18])
    guard();


// TODO: genestealer entry, breach, ladders, power field, space marine controlled area,
// force barrier, psi counter, assault cannon counter, command point counter