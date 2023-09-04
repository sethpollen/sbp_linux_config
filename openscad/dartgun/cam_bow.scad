include <common.scad>
include <../extrude_and_chamfer.scad>
include <../morph.scad>

cam_lip = 1.25;
cam_thickness = string_diameter + 2*cam_lip;
cam_cavity_diameter = cam_thickness + extra_loose;
cam_diameter = 18;
cam_length = 45;

cleat_diameter = 7;
cleat_offset = cam_diameter/2;

module cam_2d(cleat_recess=true) {
  // The back of the cam, which has a simple shape and faces away from you.
  difference() {
    hull() {
      intersection() {
        for (x = [0, cam_length - cam_diameter])
          translate([x, 0, 0])
            circle(d=cam_diameter);
        translate([-cam_diameter/2, -cam_length, 0])
          square(cam_length);
      }
    }
    
    if (cleat_recess)
      // Cutout to make it easy to thread the string through the cleat.
      translate([cleat_offset, -cam_diameter/2 - cleat_diameter*0.3, 0])
        circle(d=cleat_diameter*1.2);
  }
  
  // The front of the cam, which has a gradual increase in radius (like
  // most cams).
  polygon([
    for (a = [0 : 1/40 : 1])
      (cam_diameter/2 + (1-cos(a * 90)) * (cam_length - cam_diameter))
      * [-cos(a*180), sin(a*180)]
  ]);
}

string_groove_depth = string_diameter*0.4;

module make_cam_exterior() {
  // The cam is a delicate piece; morph it with high precision.
  $zstep = 0.1;

  // Exterior, with an octagonal groove for the string.
  morph([
    [0, [foot]],
    [foot, [0]],
    [cam_lip, [0]],
    [cam_lip + string_groove_depth, [string_groove_depth]],
    [cam_thickness - cam_lip - string_groove_depth, [string_groove_depth]],
    [cam_thickness - cam_lip, [0]],
    [cam_thickness, [0]],
  ])
    offset(-$m[0])
      children();
}

module cam() {
  difference() {
    union() {
      make_cam_exterior()
        cam_2d();
    
      // Cleat.
      translate([cleat_offset, -cam_diameter/2-cleat_diameter/2, 0]) {
        make_cam_exterior()
          circle(d=cleat_diameter);
      
        // Plates joining cleat to cam.
        translate([-cleat_diameter/2, 0, 0])
          flare_cube([cleat_diameter, cleat_diameter, cam_lip], foot);
        translate([-cleat_diameter/2, 0, cam_thickness - cam_lip])
          cube([cleat_diameter, cleat_diameter, cam_lip], foot);
      }
    }
        
    // Hole for roller. Add $zstep/2 since the cam might be slightly
    // thicker than requested (due to morph).
    translate([0, 0, -eps])
      extrude_and_chamfer(cam_thickness + 2*eps + $zstep/2, -foot, -0.2)
        circle(d=roller_diameter+loose);
  }
}

// Need beefy tubes because they have fewer reinforcing struts.
tube_wall = 5;

// Extension of roller into walls at its ends.
roller_end = 3;

// Make the tubes slightly closer.
tube_nudge = 3;

limb_diameter = tube_id + 2*tube_wall;
limb_breadth = 2*tube_id + 4*tube_wall + cam_cavity_diameter + 2*roller_end - 2*tube_nudge;

roller_cavity_length = limb_breadth - 2*tube_wall;

limb_base_thickness = 2.5;

// Cross-section of the limb.
module limb_2d(cam_cavity=false, spring_cavity=false, roller_cavity=false) {
  difference() {
    // Exterior.
    hull()
      for (a = [-1, 1])
        translate([a*(limb_diameter-limb_breadth)/2, 0, 0])
          circle(d=limb_diameter);
      
    if (cam_cavity) {
      square([cam_cavity_diameter, limb_diameter+2*eps], center=true);
        
      // Slightly chamfer the edge of the gap.
      translate([0, limb_diameter/2, 0])
        rotate([0, 0, 45])
          square(cam_cavity_diameter/sqrt(2)+1, center=true);
    }
    
    if (spring_cavity) {
      for (a = [-1, 1])
        translate([a*(tube_id/2 + tube_wall + cam_cavity_diameter/2 - tube_nudge), 0, 0])
          circle(d=tube_id);
    }
    
    if (roller_cavity) {
      square([roller_cavity_length, roller_cavity_diameter], center=true);
    }
    
    // We always cut out a slot for the string when it is in the rest position.
    // This is only on the side of the limb that faces you.
    translate([0, -limb_diameter/2 - roller_cavity_diameter/2, 0])
      square([cam_cavity_diameter, limb_diameter+2*eps], center=true);

    // Slightly chamfer the edge of the gap.
    translate([0, -limb_diameter/2, 0])
      rotate([0, 0, 45])
        square(cam_cavity_diameter/sqrt(2)+1, center=true);
  }
}

// With these cams we probably don't need to push the spring all the way.
effective_spring_min_length = spring_min_length + 2;

module limb() {
  // A smooth inner tube helps accommodate the spring.
  $fa = 5;

  // How far beyond the roller does the cam extend? Add 1 for safe clearance
  // at the bottom of the limb.
  cam_overhang = 1 + (cam_diameter - roller_diameter) / 2;

  // Add a generous 10mm of extra length to make it easier to assemble.
  // In the final version we can make this shorter, but for now we want to
  // experiment with different points on the spring's curve.
  tube_inner_length = spring_max_length + roller_diameter + 10;
  
  linear_extrude(limb_base_thickness)
    limb_2d();
  
  translate([0, 0, limb_base_thickness])
    linear_extrude(effective_spring_min_length - cam_overhang)
      limb_2d(spring_cavity=true);
  
  translate([0, 0, limb_base_thickness + effective_spring_min_length - cam_overhang])
    linear_extrude(cam_overhang)
      limb_2d(spring_cavity=true, cam_cavity=true);
  
  translate([0, 0, limb_base_thickness + effective_spring_min_length])
    linear_extrude(tube_inner_length - effective_spring_min_length)
      limb_2d(spring_cavity=true, cam_cavity=true, roller_cavity=true);
}

// Should be wide enough to accommodate whatever bore structure we want.
barrel_od = 20;

// External parts may intrude this far into the barrel slots.
barrel_wall = 2;

limb();


////////////////////////////////////////////////////////////////////////////
// Material below needs revisiting.

// This seems like a nice choice for the bore. The dart moves relatively easily
// when pushed, but it will stay in place if not pushed (even if jerked around
// somewhat).
bore_id = dart_diameter + loose;

// The end of the barrel is wider than the bore. We don't want to slow
// the dart down after the string has stopped pushing it.
muzzle_id = dart_diameter + 1.5;
muzzle_length = 30;

barrel_od = muzzle_id + 4;

module muzzle_2d() {
  difference() {
    square(barrel_od, center=true);
    circle(d=muzzle_id);
  }
}

module bore_2d() {
  // Accuracy is important here.
  $fa = 5;

  difference() {
    square(barrel_od, center=true);
    circle(d=bore_id);
    square([barrel_od+2*eps, cam_cavity_diameter], center=true);
  }
}

trigger_width = 6;

sear_height = 3;
sear_length = 7;

// Width of the fingers which pull back the follower.
forend_finger_width = 10;

follower_width = barrel_od + 2*forend_finger_width + 2*string_groove_depth;
follower_length = sear_length + string_diameter + 2.5;

follower_od = bore_id - extra_loose;

string_tunnel_diameter = string_diameter + 0.6;

// Just a guess.
// TODO: refine this
travel = 80;

module chamfered_cylinder(h, d, chamfer) {
  flare_cylinder(h/2, d/2, chamfer);
  translate([0, 0, h-eps])
    scale([1, 1, -1])
      flare_cylinder(h/2+eps, d/2, chamfer);
}

module follower() {
  chamfer = 0.6;
  
  // Accuracy is important here.
  $fa = 5;

  front_wall = sear_length;

  difference() {
    // Wings.
    hull() {
      translate([-follower_width/2, 0, -cam_thickness/2])
        chamfered_cube([follower_width, 3, cam_thickness], chamfer);
      translate([-(follower_od+4)/2, follower_length-2, -cam_thickness/2])
        chamfered_cube([follower_od+4, 2, cam_thickness], chamfer);
    }
    
    // String tunnel.
    translate([-follower_width/2-eps, string_tunnel_diameter/2 + front_wall, 0])
      rotate([0, 90, 0])
        linear_extrude(follower_width+2*eps)
          octagon(string_tunnel_diameter);
    
    // Curved tunnel ends.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([follower_width/2 - front_wall - string_groove_depth, -eps, 0])
          rotate_extrude(angle=90)
            translate([string_tunnel_diameter/2 + front_wall, 0, 0])
              octagon(string_tunnel_diameter);
    
    // Sear slot.
    translate([-(trigger_width+1)/2, -eps, -eps-cam_thickness/2])
      cube([trigger_width+1, sear_length, sear_height+snug]);
  }
  
  // Add a tail to keep the next dart from falling down until we are ready
  // for it.
  tail_width = 4;
  translate([0, follower_length-chamfer, cam_thickness/2 - tail_width/2]) {
    rotate([-90, 0, 0]) {
      linear_extrude(travel-follower_length+chamfer)
        octagon(tail_width);
      translate([0, 0, travel-follower_length+chamfer]) {
        hull() {
          linear_extrude(eps) octagon(tail_width);
          translate([0, 0, chamfer]) linear_extrude(eps) octagon(tail_width-2*chamfer);
        }
      }
    }
  }
}

module trigger_2d() {
  // Accuracy is important here.
  $fa = 5;

  sear_chamfer = 0.6;
  ring_thickness = 3;

  sear_arm_length = 30;
  sear_arm_height = roller_diameter+2;
  
  trigger_length = 10;
  trigger_height = 25;
  
  difference() {
    union() {
      // Sear.
      polygon([
        [-sear_length, -1],
        [-2, sear_height],
        [-sear_chamfer, sear_height],
        [0, sear_height-sear_chamfer],
        [0, -sear_arm_height],
        [-sear_length, -sear_arm_height*0.6],
      ]);
      
      // Arm.
      translate([0, -sear_arm_height, 0])
        square([sear_arm_length + trigger_length, sear_arm_height]);
      
      // The trigger itself.
      translate([sear_arm_length + trigger_length, -sear_arm_height, 0])
        rotate([0, 0, -7])
          translate([-trigger_length, -trigger_height, 0])
            square([trigger_length, trigger_height]);
      
      // Ring around pivot pin.
      translate([sear_arm_length, -(roller_diameter+loose)/2, 0])
        circle(d=roller_diameter+loose+ring_thickness*2);
    }
    
    // Hole for pivot pin.
    translate([sear_arm_length, -(roller_diameter+loose)/2, 0])
      circle(d=roller_diameter+loose);
  }
}

module trigger() {
  translate([0, trigger_width/2, 0]) {
    rotate([90, 0, 0]) {
      morph([
        [0, [foot]],
        [foot, [0]],
        [trigger_width, [0]],
      ])
        offset(-$m[0]) trigger_2d();
    }
  }
}

