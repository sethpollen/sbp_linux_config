side = 30;
height = 3.2;
hook_width = 2.1;
hook_protrusion_length = 5.2;
hook_arm_length = 3.5;

slack = 0.7;
side_loose = 0.8;

chamfer = 0.6;

eps = 0.0001;

module stack(h) {
  linear_extrude(h) children(0);
  if ($children > 1)
    translate([0, 0, h]) children(1);
}

module hook_2d(protrude=true, arm=true) {
  $fn = 30;
  
  intersection() {
    chop_top = 1;
    translate([0, chop_top])
      square([hook_width, height - chop_top]);
    
    // Gently rounded.
    translate([hook_width - 4.8, 0])
      rotate([0, 0, 12])
        square(10, center=true);
    
    // Elephant foot.
    translate([hook_width - 4.8, 0])
      rotate([0, 0, 45])
        square(10, center=true);
    
    if (!protrude)
      translate([0, height/2 + 0.2])
        square(10);
  }

  if (arm)
    translate([-hook_width, height/2 + 0.2])
      square([hook_width, height/2 - 0.2]);
}

module hook() {
  difference() {
    rotate([-90, 0, 0]) {
      translate([slack/2, -height, -hook_arm_length - hook_protrusion_length/2]) {
        stack(hook_arm_length - side_loose/2) {
          hook_2d(protrude=false);
          stack(side_loose/2) {
            hook_2d(protrude=false, arm=false);
            stack(hook_protrusion_length) {
              hook_2d(arm=false);
              stack(side_loose/2) {
                hook_2d(protrude=false, arm=false);
                stack(hook_arm_length - side_loose/2) {
                  hook_2d(protrude=false);
                }
              }
            }
          }
        }
      }
    }
    
    cham = chamfer * sqrt(2);
    for (a = [-1, 1])
      translate([0, a * (hook_arm_length + hook_protrusion_length/2), 0])
        rotate([45, 0, 0])
          cube([10, cham, cham], center=true);
    
    // Round off corners.
    for (a = [-1, 1])
      scale([1, a, 1])
        translate([hook_width, hook_arm_length + hook_protrusion_length/2, 0])
          rotate([0, 0, -45])
            cube([10, 0.7, 10], center=true);
  }
  
  translate([0.8, 0, 1.9])
    cube([hook_width + 0.3, hook_protrusion_length - 0.8, 1], center=true);
}

module hole() {
  translate([-hook_width/2, 0, 0]) {
    translate([0, 0, -1])
      linear_extrude(height+2)
        square([hook_width + slack, hook_protrusion_length + side_loose], center=true);
    
    translate([0, 0, height/2 - 0.2])
      linear_extrude(height+2)
        square([hook_width + slack, hook_protrusion_length + side_loose + 2*hook_arm_length], center=true);
    
    // Foot inside hole.
    translate([0, 0, -1])
      linear_extrude(1.2)
        offset(0.25, $fn=12)
          square([hook_width + slack, hook_protrusion_length + side_loose], center=true);
  }
}

module piece_2d(recede) {
  roundoff = 0.8;
  $fn = 16;

  offset(roundoff)
    offset(-roundoff-recede)
      square(side, center=true);
}

module piece_exterior() {
  difference() {
    hull() {
      translate([0, 0, height/2])
        linear_extrude(height/2)
          piece_2d(chamfer);
      
      // Slightly stronger chamfer on bottom.
      linear_extrude(height/2)
        piece_2d(chamfer*1.2);

      translate([0, 0, chamfer])
        linear_extrude(height - 2*chamfer)
          piece_2d(0);
    }
    
    translate([0, 0, -1])
      linear_extrude(1.4)
        offset(0.2)
          gnurl_2d();
    
    translate([0, 0, height-0.4])
      linear_extrude(1)
        gnurl_2d();
  }
}

module piece() {
  difference() {
    union() {
      piece_exterior();
      
      for (a = [0:3])
        rotate([0, 0, a*90])
          translate([side/2, 0, 0])
            hook();
    }
    
    for (a = [0:3])
      rotate([0, 0, a*90])
        translate([side/2, 0, 0])
          hole();
  }
}

module gnurl_2d() {
  repeat = 10;
  spacing = 4.3;
  rotate([0, 0, 45])
    for (a = [-repeat:repeat], b = [-repeat:repeat])
      translate(spacing * [a, b])
        square(1.6, center=true);
}

piece();