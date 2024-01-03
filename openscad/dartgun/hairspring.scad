include <common.scad>
include <clips.scad>
include <barrel.scad>
include <screw.scad>
include <spiral.scad>

socket_diameter = 7;
spring_height = 12;
spring_hub_diameter = 15;
spring_thickness = 3;
spring_gap = 3;
spring_turns = 5;

module hairspring_2d(foot=0) {
  start_radius = spring_hub_diameter/2 - spring_thickness/2;
  slope = spring_thickness + spring_gap;
  
  difference() {
    union() {
      circle(d=spring_hub_diameter-2*foot);
      spiral(start_radius, slope, spring_turns, spring_thickness-2*foot);
    }

    // Square off the loose end.
    rotate([0, 0, spring_turns*360])
      translate([start_radius + slope*spring_turns, spring_thickness/2 + spring_gap/2])
        square(spring_thickness + spring_gap, center=true);
  }
  
  // Add a handle on the end, as requested by the caller.
  handle_id = nail_loose_diameter;
  handle_od = handle_id + 2*spring_thickness;
  
  rotate([0, 0, spring_turns*360]) {
    translate([start_radius + slope*spring_turns + handle_od/2 - spring_thickness/2, 0]) {
      difference() {
        circle(d=handle_od - 2*foot);
        circle(d=handle_id + 2*foot);
      }
    }
  }
}

// The distance between the centers of the two holes.
spring_hole_spacing =
  spring_hub_diameter/2 + spring_thickness/2 + (spring_thickness + spring_gap) * spring_turns + snug;

// Print with 20% cubic infill.
module spring() {
  handle_diameter = 10;
  step_foot = 0.28;
    
  difference() {
    union() {
      translate([0, 0, step_foot])
        linear_extrude(spring_height-step_foot)
          hairspring_2d();
      
      linear_extrude(0.3)
        hairspring_2d(foot=step_foot);
    }
    
    // Socket.
    for (a = [0, 45])
      rotate([0, 0, a])
        translate([-socket_diameter/2, -socket_diameter/2, -eps])
          flare_cube([socket_diameter, socket_diameter, spring_height+2*eps], -foot);
    
    // Marker pointing to the outer end. This allows us to gauge relaxation of the
    // spring over its useful life.
    translate([6, 0, spring_height])
      rotate([45, 0, 0])
        cube([5, 1, 1], center=true);
  }
  
  // Brim for extreme end.
  linear_extrude(0.2) {
    difference() {
      translate([spring_hole_spacing+3, -(handle_diameter-3)/2])
        square([6, handle_diameter-3]);
      hairspring_2d();
    }
  }
}

module spring_print() {
  // Orient the spring so that Cura puts the seam on the handle rather than midway
  // along the outer loop.
  rotate([0, 0, 180])
    spring();
}

// Original cams had maj=50 and min=18.2. This gave a very tight string in
// the neutral position but a disappointing muzzle velocity. Here we are
// trying some other settings:
cam_major_diameter = 45;
cam_minor_diameter = 25;
cam_thickness = 12;
cam_inset = 4;

module cam_2d() {
  intersection() {
    translate([0, 50, 0]) square(100, center=true);
    circle(d=cam_major_diameter);
  }
  intersection() {
    translate([0, -50, 0]) square(100, center=true);
    hull()
      for (a = [-1, 1])
        translate([a*(cam_major_diameter-cam_minor_diameter)/2, 0, 0])
          circle(d=cam_minor_diameter);
  }
}

module cam_slice(thickness, top_inset, bottom_inset) {
  hull() {
    linear_extrude(eps)
      offset(bottom_inset)
        cam_2d();
    translate([0, 0, thickness])
      linear_extrude(eps)
        offset(top_inset)
          cam_2d();
  }
}

// Print with 10% triangle infill.
module cam() {
  // Profile.
  bottom_flat = 0.8;
  middle_flat = 2;
  incline = (cam_thickness - 2*bottom_flat - middle_flat) / 2;
  
  // Center the whole thing on the middle of the hole.
  translate([-cam_major_diameter/2 + cam_minor_diameter/2, 0, 0]) {
    difference() {
      union() {
        cam_slice(foot, 0, -foot);
        translate([0, 0, foot])
          cam_slice(bottom_flat-foot, 0, 0);
        translate([0, 0, bottom_flat])
          cam_slice(incline, -cam_inset, 0);
        translate([0, 0, bottom_flat+incline])
          cam_slice(middle_flat, -cam_inset, -cam_inset);
        translate([0, 0, bottom_flat+incline+middle_flat])
          cam_slice(incline, 0, -cam_inset);
        translate([0, 0, bottom_flat+incline+middle_flat+incline])
          cam_slice(bottom_flat, 0, 0);
      }
      
      translate([(cam_major_diameter-cam_minor_diameter-socket_diameter)/2, -socket_diameter/2, -eps])
        flare_cube([socket_diameter, socket_diameter, cam_thickness+3*eps], -foot);
    }
    
    // Holder for end of string.
    translate([-3, -cam_thickness/2 - cam_minor_diameter/2 + cam_inset + 1.7, cam_thickness/2]) {
      difference() {
        // Exterior.
        translate(-cam_thickness/2 * [1, 1, 1])
          chamfered_cube(cam_thickness * [1, 1, 1], 0.7);
        
        // Socket for knot.
        knot_diameter = 9.5;
        translate([-3, -knot_diameter/2, -knot_diameter/2])
          chamfered_cube([cam_thickness, knot_diameter, knot_diameter], 2);
        
        // Hole for string.
        narrow_string_diameter = 4;
        translate([-cam_thickness, -16, -narrow_string_diameter/2])
          chamfered_cube([cam_thickness*2, 20, narrow_string_diameter], 1);
      }
    }
  }
}

pin_length = spring_height*4 + cam_thickness;
pin_width = socket_diameter - snug;

// Print with 40% grid infill.
module pin() {
  rotate([90, 0, 0]) {
    difference() {
      translate([-pin_width/2, -pin_width/2, 0])
        chamfered_cube([pin_width, pin_width, pin_length], foot);
      translate([0, 0, -eps])
        linear_extrude(pin_length+2*eps)
          // Make the fit extra loose, since this joint will be subjected to high speed.
          octagon(nail_loose_diameter+0.2);
    
      // Extra chamfer on ends so the printer doesn't flare the ends.
      extra_chamfer = 1.4;
      for (a = [-1, 1], b = [0, 90], c = [-1, 1]) {
        rotate([0, 0, b]) {
          scale([a, 1, c]) {
            translate([pin_width/2-extra_chamfer+eps, pin_width/2, c == 1 ? -eps : -pin_length-eps]) {
              rotate([90, 0, 0]) {
                scale([1, 2, 1]) {
                  difference() {
                    cube([extra_chamfer, extra_chamfer, pin_width]);
                    translate([0, extra_chamfer, 0])
                      cylinder(pin_width, r=extra_chamfer);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module dome_2d(r) {
  circle(r);
  translate([0, -r/2])
    square([2*r, r], center=true);
}

// Include room for 4 stacked springs.
// Add 2 extra millimeters for plenty of clearance.
spring_cavity_height = spring_height*4 + cam_thickness + 2;

bracket_plate_thickness = 6;
bracket_height = spring_cavity_height + 2*bracket_plate_thickness;

retention_plate_length = spring_hole_spacing + retention_clip_length;

// Additional space by which the magazine can intrude forwards into the
// bracket.
bracket_mag_lap = 15;

// Distance from back wall of bracket, forward to the spring holes.
bracket_back_length = 30;

bracket_mag_intrusion = 2*mag_front_back_wall + feed_cut_length + bracket_mag_lap;
bracket_length = bracket_mag_intrusion + 65;

spring_cavity_radius = spring_hole_spacing + 1.5*spring_thickness;

bracket_inner_wall = enclosure_wall + 7;

bracket_tip_length = bracket_back_length + 20;
bracket_back_width = barrel_width + 2*bracket_inner_wall + 2*spring_cavity_radius + 20;

pin_hole_x1 = barrel_width/2 + bracket_inner_wall + spring_thickness*1.5;
pin_hole_x2 = pin_hole_x1 + spring_hole_spacing;

foregrip_block_length = 50;
// Thinner walls than normal, to help it fit.
foregrip_block_wall = 4;
foregrip_block_width = barrel_width + 2*foregrip_block_wall;
foregrip_block_height = barrel_height + 2*enclosure_wall;

// Wall in front of foregrip block.
bracket_front_wall = 9;

module bracket_exterior() {
  difference() {
    hull() {
      // Central rail.
      linear_extrude(bracket_length)
        square([barrel_width + enclosure_wall*2 + foregrip_block_wall*2, bracket_height], center=true);

      // Back wall, chamfered. Subtract 1 from the Z coordinate to increase contact with build
      // plate.
      for (a = [-1, 1])
        translate([a * (bracket_back_width/2 - bracket_back_length), bracket_height/2, bracket_back_length-1])
          rotate([90, 0, 0])
            cylinder(h=bracket_height, r=bracket_back_length);
    }
    
    // Cut off anything with a negative Z coordinate.
    translate([0, 0, -150])
      cube(300, center=true);
    
    // Weight saving cutout: side.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([
          barrel_width/2 + enclosure_wall + foregrip_block_wall,
          -110 + spring_cavity_height/2,
          spring_cavity_radius + bracket_back_length + 8
        ])
          chamfered_cube([100, 100, 200], 7);
    
    // Weight saving cutout: bottom front.
    hull()
      for (yz = [[-15, 0], [0, 15]])
        translate([
          -100,
          yz[0] + -200 - barrel_height/2 - enclosure_wall - 2,
          yz[1] + spring_cavity_radius + bracket_back_length - 7])
            cube(200);

    // Weight saving cutout: bottom back.
    scale([1.2, 1, 1])
      translate([0, 5 - 40 - bracket_height/2, -eps])
        cylinder(h=bracket_length/2, r1=30, r2=47.5, $fn=60);
      
    // Weight saving cutout: top front.
    translate([0, bracket_height/2, bracket_length])
      rotate([25, 0, 0])
        cube([100, 24, 100], center=true);
  }
}

module bracket_intermediate() {
  string_rest = bracket_inner_wall + spring_thickness - 0.4;
  string_rest_flat = 6;
  
  clip_xyz = [
    pin_hole_x1 - retention_clip_length/2,
    bracket_height/2 + retention_plate_thickness,
    retention_plate_width/2 + bracket_back_length
  ];
  clip_r = [90, 90, 0];
  
  difference() {
    intersection() {
      bracket_exterior();
      
      // Round off sharp corners at the very front.
      pyramid_height = bracket_length + barrel_height;
      linear_extrude(pyramid_height, scale=0)
        rotate([0, 0, 45])
          square(2*pyramid_height, center=true);
    }
    
    // Barrel cavity.
    linear_extrude(bracket_length + eps)
      square([barrel_width + loose, barrel_height + loose], center=true);
    
    // Cuts in back for string rest.
    cube(
      [barrel_width + 2*bracket_inner_wall + 2*eps, cam_thickness, 2*string_rest],
      center=true
    );
    
    // Top cut for magazine.
    translate([-(barrel_width + loose)/2, 0, -eps])
      cube([barrel_width + loose, bracket_height, bracket_mag_intrusion]);
    
    // Spring cavities.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([
          spring_cavity_radius + barrel_width/2 + bracket_inner_wall,
          0,
          bracket_back_length
        ])
          rotate([90, 0, 0])
            translate([0, 0, -spring_cavity_height/2])
              linear_extrude(spring_cavity_height)
                dome_2d(spring_cavity_radius);

    // Pin holes.
    for (x = [pin_hole_x1, pin_hole_x2, -pin_hole_x1, -pin_hole_x2])
      translate([x, 0, bracket_back_length])
        rotate([90, 0, 0])
          translate([0, 0, -bracket_height/2-eps])
            linear_extrude(bracket_height+2*eps)
              octagon(nail_loose_diameter);
    
    // Retention plate nut holes.
    for (a = [-1, 1], b = [-1, 1])
      scale([a, b, 1])
        translate(clip_xyz)
          rotate(clip_r)
            retention_nut_hole(retention_plate_length);
    
    // Cavity for foregrip block.
    translate([
      0,
      -100 + barrel_height/2 + enclosure_wall + loose/2,
      bracket_length - bracket_front_wall - foregrip_block_length/2
    ])
      cube([foregrip_block_width + loose, 200, foregrip_block_length + loose], center=true);
  }
  
  // A volume on each side which has a curved back (string rest) and which keeps
  // the springs spaced apart vertically.
  for (a = [-1, 1]) {
    scale([a, 1, 1]) {
      translate([(barrel_width + loose)/2, 0, string_rest - string_rest_flat]) {
        hull() {
          translate([string_rest/2, 0, bracket_back_length*2])
            cube([string_rest, cam_thickness, eps], center=true);
          
          translate([string_rest_flat/2, 0, -string_rest + string_rest_flat])
            cube([string_rest_flat, cam_thickness, eps], center=true);
          
          translate([string_rest_flat, 0, 0]) {
            intersection() {
              rotate([90, 0, 0])
                translate([0, 0, -cam_thickness/2])
                  cylinder(h=cam_thickness, r= string_rest - string_rest_flat);
              
              translate([string_rest, 0, -string_rest])
                cube(2*string_rest, center=true);
            }
          }
        }
      }
    }
  }
  
  // Retention plate clips.
  for (a = [-1, 1], b = [-1, 1])
    scale([a, b, 1])
      translate(clip_xyz)
        rotate(clip_r)
          retention_plate_clips(retention_plate_length);
}

module bracket() {
  intrusion(bracket_length - bracket_front_wall - foregrip_block_length - loose);
  
  difference() {
    bracket_intermediate();
    
    // Slightly flare the back of the barrel cavity, in case the sides pinch in
    // when under tension.
    flare = 0.8;
    hull() {
      translate([0, 0, -eps])
        linear_extrude(eps)
          square([barrel_width + loose + flare, barrel_height + loose + flare], center=true);
      translate([0, 0, bracket_back_length])
        linear_extrude(eps)
          square([barrel_width + loose, barrel_height + loose], center=true);
    }
  }
}

bracket();
