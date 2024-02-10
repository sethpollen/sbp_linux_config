eps = 0.0001;
$fn = 20;

side = 30;
roundoff = 1;
height = 3.2;

nub_length = 2;
nub_diameter = 3.2;

paddle_width = 6;

module nub() {
  rotate([0, 90, 0])
    linear_extrude(nub_length-0.3, scale=0.5)
      circle(d=nub_diameter);
}

module paddle() {
  translate([0, -height/2, height/2]) {
    translate([paddle_width/2, 0]) {
      rotate([0, -90, 0]) {
        linear_extrude(paddle_width) {
          circle(d=height);
          translate([-height/2, 0])
            square([height, height/2 + 5]);
        }
      }
    }
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([paddle_width/2, 0])
          nub();
  }
}

module split_paddle() {
  for (a = [-1, 1]) {
    scale([a, 1, 1]) {
      translate([paddle_width + nub_length, 0, 0]) {
        intersection() {
          paddle();
          translate([-10, -5, 0])
            cube(10);
        }
      }
    }
  }
}

chamfer = 0.8;

module piece() {
  difference() {
    hull() {
      linear_extrude(height)
        offset(roundoff)
          square(side - 2*roundoff - 2*chamfer, center=true);
      translate([0, 0, chamfer])
        linear_extrude(height - 2*chamfer)
          offset(roundoff)
            square(side - 2*roundoff, center=true);
    }
    
    for (a = [0, 90])
      rotate([0, 0, a])
        translate([0, side/2 + 5 - height + nub_diameter/8, 0])
          cube([paddle_width + 2*nub_length, 10, 10], center=true);
    
    for (a = [180, 270])
      rotate([0, 0, a])
        translate([0, side/2 + 5 - height + nub_diameter/8, 0])
          cube([2*paddle_width + 2*nub_length + 0.4, 10, 10], center=true);
  }
  
  for (a = [0, 90])
    rotate([0, 0, a])
      translate([0, -side/2 + nub_diameter/8, 0])
        paddle();

  for (a = [180, 270])
    rotate([0, 0, a])
      translate([0, -side/2 + nub_diameter/8, 0])
        split_paddle();
}

module defoot() {
  layer = 0.1;

  difference() {
    children();
    translate([0, 0, 2*layer-500])
      cube(1000, center=true);
  }
  
  linear_extrude(layer)
    offset(-0.3)
      projection(cut = true)
        translate([0, 0, -0.5*layer])
          children();

  translate([0, 0, layer])
    linear_extrude(layer)
      offset(-0.1)
        projection(cut = true)
          translate([0, 0, -1.5*layer])
            children();
}

defoot() piece();
