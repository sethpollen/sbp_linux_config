include <common.scad>

// 3/8" aluminum rod.
rod = 9.8;

length = 40;
block_height = 8;

module rod_2d() {
  circle(d=rod);
}

module rail_2d() {
  difference() {
    translate([-length/2, rod/4])
      square([length, block_height]);
    circle(d=rod + loose);
  }
}

shelf_x = 2;
ramp_x = 4;
ramp_y = rod / 4;

module ramp_2d() {
  translate([0, -rod/2 - block_height - loose/2]) {
    translate([-shelf_x, 0])
      square([length / 2 + shelf_x, block_height]);
    hull() {
      translate([-shelf_x, 0])
        square([eps, block_height]);
      translate([-shelf_x - ramp_x, 0])
        square([eps, block_height - ramp_y]);
    }
    translate([-length/2, 0])
      square([length/2 - shelf_x - ramp_x, block_height - ramp_y]);
  }
}

module track_2d(hole=true, wall=4) {
  rail_width = 5;
  
  translate([0, -rod/8]) {
    difference() {
      square([rod + 2*rail_width, block_height*2 + rod - ramp_y + rail_width], center=true);
    
      if (hole)
        square([rod + loose, block_height*2 + rod - ramp_y + rail_width - wall], center=true);
    }
  }
}

function sum(list, start, limit) =
  start == limit
  ? 0
  : list[start] + sum(list, start + 1, limit);

module stack(z) {
  for (i = [0 : $children-1])
    translate([0, 0, sum(z, 0, i)])
      linear_extrude(z[i] + eps)
        children(i);
}

sliding_height = 4;

module housing() {
  stack([2, 3, sliding_height + 0.4, 1, 2]) {
    track_2d(false);
    
    track_2d(true);
    
    difference() {
      track_2d(true);
      offset(loose/2) {
        rail_2d();
        ramp_2d();
      }
    }
    
    track_2d(true);
    track_2d(true, 8);
  }
}

module extrude_foot(height) {
  linear_extrude(0.2)
    offset(-0.2)
      children();
  translate([0, 0, 0.2])
    linear_extrude(height - 0.2)
      children();
}

housing();

translate([17, 0])
  extrude_foot(8 + sliding_height)
    rod_2d();

translate([0, 28])
  extrude_foot(sliding_height)
    ramp_2d();

translate([0, -28])
  extrude_foot(sliding_height)
    rail_2d();
