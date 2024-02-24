use <stack.scad>

eps = 0.001;
side = 29;
corner = 7;

module skull_2d() {
  $fn = 30;
  
  scale(1 * [1, 1]) {
    difference() {
      union() {
        translate([0, -0.5])
          circle(d=13.5);
        translate([0, -5])
          square([10, 6], center=true);
      }
      
      // Eyeballs.
      for (x = 3 * [-1, 1])
        translate([x, -1.8])
          circle(d=3.6);
      
      // Nose.
      translate([0, -3]) {
        hull() {
          square(eps, center=true);
          translate([0, -2.8])
            square([3.4, eps], center=true);
        }
      }
    }
    
    // Angry eyes.
    for (a = [-1, 1])
      scale([a, 1])
        translate([2, -8.8])
          translate([0, 10])
            rotate([0, 0, 20])
              square(5, center=true);
    
    // Teeth.
    for (x = [-4.2, -1.39, 1.39, 4.2])
      translate([x, -8])
        square([1.6, 3], center=true);
  }
}

module tile_2d() {
  difference() {
    square(side, center=true);
    for (a = [0, 90, 180, 270])
      rotate([0, 0, a])
        translate([side/2, side/2])
          rotate([0, 0, 45])
            square(corner, center=true);
  }
}

rail_width = 1.4;
rail_height = 1.4;
rail_cavity_offs = 0.4;

module rail_2d() {
  difference() {
    offset(-3) tile_2d();
    offset(-3-rail_width) tile_2d();
  }
}

module rail_stack(height) {
  stack(height - 0.4) {
    children();
    stack(0.2) {
      offset(-0.15) children();
      stack(0.2) {
        offset(-0.35) children();
      }
    }
  }
}

module rail() {
  rail_stack(rail_height)
    rail_2d();
}

module rail_cavity() {
  rail_stack(rail_height + rail_cavity_offs)
    offset(rail_cavity_offs)
      rail_2d();
  
  // Prevent elephant foot.
  linear_extrude(0.2)
    offset(rail_cavity_offs + 0.2)
      rail_2d();
}

tile_height = 4;
chamfer = 0.8;
skull_depth = 1.4;

module tile(skull=false) {
  difference() {
    hull() {
      translate([0, 0, tile_height/2])
        linear_extrude(tile_height/2)
          offset(-chamfer)
            tile_2d();
      
      // Slightly stronger chamfer on bottom.
      linear_extrude(tile_height/2)
        offset(-chamfer*1.2)
          tile_2d();

      translate([0, 0, chamfer])
        linear_extrude(tile_height - 2*chamfer)
          tile_2d();
    }
    
    translate([0, 0, -eps])
      rail_cavity();
    
    if (skull) {
      translate([0, 1.7, -eps]) {
        linear_extrude(0.2)
          offset(0.26)
            skull_2d();
        linear_extrude(skull_depth)
          skull_2d();
      }
    }
  }
  
  translate([0, 0, tile_height])
    rail();
}

module skull() {
  stack(0.2) {
    offset(-0.15 - 0.24) skull_2d();
    stack(skull_depth - 0.8) {
      offset(-0.15) skull_2d();
    }
  }
}

tile(true);
translate([0, 32]) tile(false);
translate([25, 0]) skull();
