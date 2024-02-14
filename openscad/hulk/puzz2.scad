side = 30;
height = 3.2;
hook_width = 1.7;
hook_protrusion_length = 6;
hook_arm_length = 2.4;

slack = 0.7;
side_loose = 0.5;

eps = 0.0001;

module stack(h) {
  linear_extrude(h) children(0);
  if ($children > 1)
    translate([0, 0, h]) children(1);
}

module hook_2d(fillet=true, protrude=true, arm=true) {
  $fn = 60;
  
  intersection() {
    square([hook_width, height]);
    
    // Gently rounded.
    translate([hook_width - 4.8, 0])
      rotate([0, 0, 12])
        square(10, center=true);
    
    // Elephant foot.
    translate([hook_width - 4.8, 0])
      rotate([0, 0, 45])
        square(10, center=true);
    
    // Chopped corner.
    hull() {
      translate([hook_width, hook_width-0.1])
        circle(hook_width);
      translate([0, 10])
        square(10);
    }
    
    if (!protrude)
      translate([0, height/2 + 0.2])
        square(10);
  }

  if (arm)
    translate([-hook_width, height/2 + 0.2])
      square([hook_width, height/2 - 0.2]);

  if (fillet) {
    hull() {
      translate([-0.2, height - 0.2])
        square([0.4, 0.2]);
      translate([0, height - 0.4])
        square([0.4, eps]);
    }
  }
}

module hook() {
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
  chamfer = 0.6;
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

piece();