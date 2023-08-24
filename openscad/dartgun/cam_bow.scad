include <common.scad>
include <../extrude_and_chamfer.scad>

cam_lip = 1.5;
cam_thickness = string_diameter + 2*cam_lip;
cam_cavity_diameter = cam_thickness + extra_loose;
cam_diameter = 18;
cam_length = 45;

string_channel_depth = string_diameter * 0.35;

module cam() {
  difference() {
    // Exterior.
    extrude_and_chamfer(cam_thickness, foot, 0.2)
      hull()
        for (x = [0, cam_length - cam_diameter])
          translate([x, 0, 0])
            circle(d=cam_diameter);
        
    // Hole for roller.
    translate([0, 0, -eps])
      extrude_and_chamfer(cam_thickness+2*eps, -foot, -0.2)
        circle(d=roller_diameter+loose);
        
    translate([cam_length/2 - cam_diameter/2, 0, cam_thickness/2])
      cam_string_channel();
  }
}

module cam_string_channel() {
  channel_offset = cam_diameter/2 + string_diameter/2 - string_channel_depth;
  half_straight = cam_length/2 - cam_diameter/2;
  join_angle = 30;
  join_radius = half_straight / cos(join_angle) - cam_diameter/2 - (string_diameter/2 - string_channel_depth);

  translate([-half_straight - eps, channel_offset, 0])
    rotate([0, 90, 0])
      linear_extrude(cam_length - cam_diameter + 2*eps)
        circle(d=string_diameter);
  
  // Two big loops which go around the ends of the cam.
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([-half_straight, 0, 0])
        rotate([0, 0, 90])
          rotate_extrude(angle=270 - join_angle)
            translate([channel_offset, 0, 0])
              circle(d=string_diameter);
  
  // Join between the two big loops.
  translate([0, -(half_straight * tan(join_angle))-eps, 0]) {    
    rotate([0, 0, join_angle]) {
      rotate_extrude(angle=180-join_angle) {
        translate([join_radius, 0, 0]) {
          circle(d=string_diameter);
          translate([0, -string_diameter/2, 0])
            square([string_diameter/2, string_diameter]);
        }
      }
    }
    
    translate([-join_radius, eps, 0]) {
      rotate([90, 0, 0]) {
        translate([-string_diameter/2, -string_diameter/2, 0])
          cube([string_diameter/2, string_diameter, 20]);
        cylinder(20, d=string_diameter);
      }
    }
  }
  
  // Fillet in the weird joint.
  translate([-half_straight, 0, 0])
    rotate([0, 0, 270])
      rotate_extrude(angle=70 - join_angle)
        translate([channel_offset, -string_diameter/2, 0])
          square([string_diameter/2, string_diameter]);
}

//cam_string_channel();
cam();

// Need beefy tubes because they have fewer reinforcing struts.
tube_wall = 5;

// Extension of roller into walls at its ends.
roller_end = 2;

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
        
      // Slightly chamfer the edges of the gap.
      for (a = [-1, 1])
        translate([0, a*limb_diameter/2, 0])
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
  }
}

// With these cams we probably don't need to push the spring all the way.
effective_spring_min_length = spring_min_length + 4;

fillet_length = 30;
fillet_height = spring_max_length;
fillet_width = 8;
fillet_offset = 10;

module limb() {
  // How far beyond the roller does the cam extend? Add 1 for safe clearance
  // at the bottom of the limb.
  cam_overhang = 1 + (cam_diameter - roller_diameter) / 2;

  // Add a generous 10mm of extra length to make it easier to assemble.
  // In the final version we can make this shorter, but for now we want to
  // experiment with different points on the spring's curve.
  tube_inner_length = spring_max_length + roller_diameter + 10;
  
  difference() {
    union() {
      linear_extrude(limb_base_thickness)
        limb_2d();
      
      translate([0, 0, limb_base_thickness])
        linear_extrude(effective_spring_min_length - cam_overhang)
          limb_2d(spring_cavity=true);
      
      // Bottom fillet to give a strong connection to the receiver.
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([
            fillet_offset,
            limb_diameter/2-1,
            0
          ])
            rotate([90, 0, 90])
              linear_extrude(fillet_width)
                polygon([
                  [0, 0],
                  [fillet_length+1, 0],
                  [fillet_length+1, 1],
                  [0, fillet_height]
                ]);
    }
    
    limb_sockets();
  }

  translate([0, 0, limb_base_thickness + effective_spring_min_length - cam_overhang])
    linear_extrude(cam_overhang)
      limb_2d(spring_cavity=true, cam_cavity=true);
  
  translate([0, 0, limb_base_thickness + effective_spring_min_length])
    linear_extrude(tube_inner_length - effective_spring_min_length)
      limb_2d(spring_cavity=true, cam_cavity=true, roller_cavity=true);
}

module limb_sockets() {
  translate([0, -limb_diameter*0.2, 0])
    socket();
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([fillet_offset + fillet_width/2, fillet_length*0.7 + limb_diameter/2, 0])
        socket();
}

module print() {
  limb();
  scale([1, -1, 1]) translate([-15, -55, 0]) cam();
}
