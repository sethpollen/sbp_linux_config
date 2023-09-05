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

limb_base_thickness = 2.5;

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
    translate([0, -limb_diameter/2 - roller_cavity_diameter/2, 0])
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

// Should be wide enough to accommodate whatever bore structure we
// want.
barrel_width = 20;
barrel_height = 34;

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
      
      // Foot.
      translate([0, 0, limb_base_thickness + tube_inner_length - foot])
        linear_extrude(foot)
          offset(-foot)
            limb_2d(spring_cavity=true, cam_cavity=true, roller_cavity=true);  
    }
  
    // Rail cavities.
    cavity_length = rail_notch_length*9;
    // Slide the cavities away slightly so that the limbs don't quite meet each
    // other. This ensures a tight fit on the barrel.
    extra = 0.6;
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([-barrel_height/2, -cavity_length/2, -barrel_width/2 - extra])
          rotate([0, 90, 90])
            rail(barrel_width, cavity_length, barrel_height/2, cavity=true);
    
    // Complete remove one quarter of the base to allow free movement of the
    // forend where it grabs the follower.
    translate([0, -limb_diameter, -barrel_width + follower_finger_width])
      cube([limb_breadth/2, limb_diameter, barrel_width]);

    // Passage for zip tie. My medium zip ties have a cross section of 1.2x3.5mm.
    // This is slightly offset forward, since we must cut out some of the limb
    // on the bottom to accommodate the slide.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([limb_breadth/2-4, 4, -barrel_width/2])
          rotate([90, 0, 0])
            rotate_extrude(angle = 360)
              translate([4, 0, 0])
                square([2.2, 4], center=true);
  }
}

barrel_length = 244;
main_bore = dart_diameter + 1;

module barrel() {
  // Make the bore with high precision.
  $fa = 5;
  
  difference() {
    translate([0, barrel_height/2, 0])
      rail(barrel_width, barrel_length, barrel_height/2 - cam_cavity_diameter/2);
    
    translate([0, 0, -eps])
      cylinder(barrel_length+2*eps, d=main_bore);
  }
}

follower_front_wall = 3;
follower_finger_width = 6;
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

limb();

color("red")
translate([0, 0, -barrel_width/2])
rotate([90, 0, -90])
follower();