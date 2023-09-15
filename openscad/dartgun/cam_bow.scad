include <barrel.scad>
include <common.scad>
include <rail.scad>
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
  // The back of the cam, which has a simple shape and faces away
  // from you.
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

follower_finger_width = 10;

// Ensure sufficient thickness even on the bottom, where there is a cutout for
// the follower finger.
limb_base_thickness = follower_finger_width + 2.5;

// Cross-section of the limb.
module limb_2d(
  cam_cavity=false,
  spring_cavity=false,
  roller_cavity=false,
  barrel_cavity=false
) {
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
    
    if (barrel_cavity) {
      square([barrel_height+tight, limb_diameter+2*eps], center=true);
    }
    
    // We always cut out a slot for the string and follower when they are in the rest
    // position. This is only on the side of the limb that faces you.
    translate([0, -limb_diameter/2, 0])
      square([cam_cavity_diameter, limb_diameter+2*eps], center=true);

    // Slightly chamfer the edge of the gap.
    translate([0, -limb_diameter/2, 0])
      rotate([0, 0, 45])
        square(cam_cavity_diameter/sqrt(2)+1, center=true);
  }
}

// With these cams we probably don't need to push the spring all 
// the way.
effective_spring_min_length = spring_min_length + 2;

module limb() {
  // A smooth inner tube helps accommodate the spring.
  $fa = 5;

  // How far beyond the roller does the cam extend? Add 1 for safe
  // clearance at the bottom of the limb.
  cam_overhang = 1 + (cam_diameter - roller_diameter) / 2;

  // Add a generous 10mm of extra length to make it easier to assemble.
  // In the final version we can make this shorter, but for now we 
  // want to experiment with different points on the spring's curve.
  tube_inner_length = spring_max_length + roller_diameter + 10;
  
  difference() {
    union() {
      translate([0, 0, -barrel_width/2])
        linear_extrude(limb_base_thickness + barrel_width/2)
          limb_2d();
      
      translate([0, 0, limb_base_thickness])
        linear_extrude(effective_spring_min_length - cam_overhang)
          limb_2d(spring_cavity=true);
      
      translate([0, 0, limb_base_thickness + effective_spring_min_length - cam_overhang])
        linear_extrude(cam_overhang)
          limb_2d(spring_cavity=true, cam_cavity=true);
      
      translate([0, 0, limb_base_thickness + effective_spring_min_length])
        linear_extrude(tube_inner_length - effective_spring_min_length - foot)
          limb_2d(spring_cavity=true, cam_cavity=true, roller_cavity=true);
      
      // Foot on top (bottom, when printing).
      translate([0, 0, limb_base_thickness + tube_inner_length]) {
        translate([0, 0, -foot])
          linear_extrude(foot/2)
            offset(-foot/2)
              limb_2d(spring_cavity=true, cam_cavity=true, roller_cavity=true);
        translate([0, 0, -foot/2])
          linear_extrude(foot/2)
            offset(-foot)
              limb_2d(spring_cavity=true, cam_cavity=true, roller_cavity=true);
      }
            
      // Fillet in front for a strong attachment to the barrel.
      extra_width = 12;
      fillet_width = extra_width + barrel_height;
      fillet_length = 20;
      translate([-fillet_width/2, limb_diameter/2-2, 0]) {
        hull() {
          translate([0, 0, limb_base_thickness + effective_spring_min_length - cam_overhang]) {
            translate([0, 0, -4])
              cube([fillet_width, eps, eps]);
            translate([fillet_width/2-cam_cavity_diameter/2, 2, 0])
              cube([cam_cavity_diameter, eps, eps]);
          }
          translate([0, 0, -barrel_width/2])
            cube([fillet_width, fillet_length, eps]);
          translate([0, 0, 7-barrel_width/2])
            cube([fillet_width, fillet_length, eps]);
        }
      }
    }
  
    // String channel inside the fillet.
    tunnel_id = string_diameter + 1.7;
    tunnel_curve_radius = 5;
    translate([
      0,
      tunnel_curve_radius + limb_diameter/2 - 1.5,
      limb_base_thickness + effective_spring_min_length - cam_overhang
    ]) {      
      translate([0, 0, eps])
        rotate([180, 90, 0])
          rotate_extrude(angle=90)
            translate([tunnel_curve_radius + tunnel_id/2, 0, 0])
              octagon(tunnel_id);
      translate([tunnel_curve_radius + tunnel_id/2, -eps, -tunnel_curve_radius - tunnel_id/2])    
        rotate([0, 180, 0])
          rotate_extrude(angle=90)
            translate([tunnel_curve_radius + tunnel_id/2, 0, 0])
              octagon(tunnel_id);
      
      // Etch the top of the tunnel so that it prints better when inverted
      // (as bridging is needed).
      translate([0, -tunnel_curve_radius - tunnel_id/2 + 0.15, 0]) {
        hull() {
          translate([0, 0, -2])
            linear_extrude(eps)
              octagon(tunnel_id);

          linear_extrude(eps)
            square(cam_cavity_diameter, center=true);
        }
      }
    }
    
    // Similarly steeple the bridges over the rod cavity, to get neat printing.
    translate([0, 0, limb_base_thickness + effective_spring_min_length])
      rotate([45, 0, 0])
        cube([roller_cavity_length-eps, cam_cavity_diameter/sqrt(2), cam_cavity_diameter/sqrt(2)], center=true);

    // Rail cavities.
    cavity_length = rail_notch_length*17;
    // Slide the cavities away slightly so that the limbs don't quite meet each
    // other. This ensures a tight fit on the barrel.
    extra_space = 0.25;
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([-barrel_height/2, -cavity_length/2, -barrel_width/2 - extra_space])
          rotate([0, 90, 90])
            rail(barrel_width, cavity_length, barrel_height/2 - cam_cavity_diameter/2, cavity=true);
    
    // Limit the intrusion of the middle lug between the two barrel pieces.
    translate([-barrel_height/4, 0, -barrel_width-1.2])
      cube([barrel_height/2, 40, barrel_width]);
    
    // Completely remove one quarter of the base to allow free movement of the
    // forend where it grabs the follower.
    translate([-cam_cavity_diameter/2, 0, -barrel_width])
      linear_extrude(barrel_width+follower_finger_width+loose)
        polygon([
          [limb_breadth, 0],
          [23, 0],
          [13, 10],
          [0, 10],
          [0, -limb_diameter],
          [limb_breadth, -limb_diameter],
        ]);

    // Passage for zip tie. My medium zip ties have a cross section of 1.2x3.5mm.
    // This is slightly offset forward, since we must cut out some of the limb
    // on the bottom to accommodate the slide.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([limb_breadth/2-3.8, 4, -barrel_width/2])
          scale([1, 1, 2])
            rotate([90, 0, 0])
              rotate_extrude(angle = 360)
                translate([3.5, 0, 0])
                  square([2.2, 4], center=true);
  }
}

follower_front_wall = 2.5;
follower_width = barrel_width + follower_finger_width*2 + 2;

module follower() {
  tunnel_id = string_diameter + 1.2;
  
  // Enough chamfer to absort the elephant foot and then some, for smooth movement.
  chamfer = 0.7;
  
  difference() {
    union() {
      // Front piece which passes through the slots.
      outer_radius = follower_front_wall + tunnel_id*0.3;
      hull() {
        for (a = [-1, 1]) {
          scale([1, a, 1]) {
            difference() {
              translate([eps, follower_width/2 - outer_radius, -cam_thickness/2])
                rotate_extrude(angle = 90)
                  square([outer_radius, cam_thickness]);
              
              // Chamfer leading and trailing edges.
              for (b = [-1, 1])
                scale([1, 1, b])
                  for (x = [0, outer_radius])
                    translate([x, 0, cam_thickness/2])
                      cube([chamfer*2, follower_width+2*eps, chamfer*2], center=true);
            }
          }
        }
      }
      
      // Piston shape which engages with the bottom bore, to keep the follower
      // straight. We have to instantiate it twice with different radii to prevent
      // elephant's foot.
      piston_length = tunnel_id + follower_front_wall + 2;
      $fa = 5;
      intersection() {
        rotate([0, 90, 0])
          flare_cylinder(piston_length, (main_bore-extra_loose)/2, chamfer, chamfer);
        translate([0, -main_bore/2, cam_thickness/2-main_bore-0.2])
          cube([piston_length+2*eps, main_bore, main_bore]);
      }
      intersection() {
        rotate([0, 90, 0])
          flare_cylinder(piston_length, (main_bore-extra_loose)/2-0.3, chamfer, chamfer);
        translate([0, -main_bore/2, cam_thickness/2-main_bore])
          cube([piston_length+2*eps, main_bore, main_bore]);
      }
    }
    
    // String tunnel.
    translate([tunnel_id/2 + follower_front_wall, 0, 0]) {
      for (a = [-1, 1]) {
        scale([1, a, 1]) {
          translate([0, eps, 0])
            rotate([90, 0, 0])
              linear_extrude(follower_width/2 - follower_front_wall + 2*eps)
                octagon(tunnel_id);
          
          translate([-follower_front_wall - tunnel_id/2, -follower_width/2 + follower_front_wall, 0])
            rotate([0, 0, -90])
              rotate_extrude(angle = 90)
                translate([follower_front_wall + tunnel_id/2, 0, 0])
                  octagon(tunnel_id);
        }
      }
    }
  }
}

cam();