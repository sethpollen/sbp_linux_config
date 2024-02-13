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

blip_diameter = 27.2;
blip_height = chip_height - 0.6;
blip_rail_height = 1.4;
blip_rail_width = 1.4;

module blip_exterior_2d() {
  flat = 0.8;
  hull() {
    translate([0, -blip_height/2])
      square([eps, blip_height]);
    translate([blip_diameter/2 - blip_height/2, 0])
      for (y = flat * [-1, 1])
        translate([0, y])
          circle(d=blip_height-flat*2, $fn = 30);
  }
}

blip_rail_cavity_offs = 0.4;

module blip_rail_2d(cavity=false) {
  offset(cavity ? blip_rail_cavity_offs : 0) {
    hull() {
      translate([-blip_rail_width/2, 0])
        square([blip_rail_width, eps]);
      translate([0, blip_rail_height - blip_rail_width/2])
        circle(d=blip_rail_width, $fn = 30);
    }
  }
  
  // Prevent elephant foot.
  if (cavity)
    translate([-blip_rail_width/2 - 0.55, 0])
      square([blip_rail_width + 1.1, 0.2]);
}

module blip_rail(radius, cavity=false) {
  rotate_extrude($fn = 60)
    translate([radius, 0])
      blip_rail_2d(cavity=cavity);
}

module blip(count) {
  height = chip_height;
  outer_rail_radius = 9.4;
  rail_spacing = 4;

  // Top always has 1 rail.
  translate([0, 0, blip_height/2])
    blip_rail(outer_rail_radius, 0);
  
  difference() {
    rotate_extrude($fn = 60)
      blip_exterior_2d();

    translate([0, 0, -blip_height/2-eps]) {
      // Bottom always has outer rail.
      blip_rail(outer_rail_radius, cavity=true);
      
      if (count >= 2)
        blip_rail(outer_rail_radius - rail_spacing, cavity=true);
      
      if (count >= 3) {
        blip_rail(outer_rail_radius - 2*rail_spacing, cavity=true);
        cylinder(h=blip_rail_height + blip_rail_cavity_offs, r=1.28, $fn=30);
      }
    }
    
    // Etch radar on top.
    for (a = [0:14]) {
      rotate([0, 0, 7*a]) {
        translate([-0, 0, blip_height/2 - 1.4 + a*0.1]) {
          hull() {
            translate([-0.5, outer_rail_radius-0.8, 0])
              cube([1.1, eps, 10]);
            cylinder(d=1, h=10, $fn=16);
          }
        }
      }
    }
  }
}

command_points(2);

module skull_2d() {
  $fn = 30;
  
  difference() {
    union() {
      translate([0, -0.5])
        circle(d=13.5);
      translate([0, -5])
        square([10, 6], center=true);
    }
    
    // Eyeballs.
    for (x = 3 * [-1, 1])
      translate([x, -2])
        circle(d=3.5);
    
    // Nose.
    translate([0, -3]) {
      hull() {
        square(eps, center=true);
        translate([0, -2.4])
          square([2.5, eps], center=true);
      }
    }
  }
  
  // Angry eyes.
  for (a = [-1, 1])
    scale([a, 1])
      translate([2, -9])
        translate([0, 10])
          rotate([0, 0, 20])
            square(5, center=true);
  
  // Teeth.
  for (x = [-4, -1.3, 1.3, 4])
    translate([x, -8])
      square([2, 3], center=true);
}

module command_points(value) {
  height = chip_height;
  
  difference() {
    blank_chip(height, 1)
      circle(d=22, $fn=80);
    
    translate([0, 0, -3*eps], $fn = 40)
      linear_extrude(height - 1.6)
        translate([4.8, -5.4, 0])
          scale([-1, 1, 1])
            offset(0.6)
              text(str(value), size = 12);
  }
  
  translate([0, 2, height]) {
    linear_extrude(0.8) skull_2d();
    translate([0, 0, 0.8]) linear_extrude(0.2) offset(-0.2) skull_2d();
    translate([0, 0, 1]) linear_extrude(0.2) offset(-0.4) skull_2d();
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

// TODO: genestealer entry, breach, ladders, power field, space marine controlled area,
// force barrier, psi counter, assault cannon counter, command point counter