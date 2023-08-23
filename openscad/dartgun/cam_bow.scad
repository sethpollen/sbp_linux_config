include <common.scad>
include <../extrude_and_chamfer.scad>

cam_lip = 1;
cam_thickness = string_diameter + 2*cam_lip;
cam_cavity_diameter = cam_thickness + extra_loose;
cam_diameter = 18;
cam_length = 45;

string_channel_depth = string_diameter * 0.35;

cleat_diameter = 6;

// The effective diameter of curvature for the string when it passes around the cam.
cam_channel_diameter = cam_diameter - 2*string_channel_depth;

module cleat() {
  difference() {
    // Exterior.
    extrude_and_chamfer(cam_thickness, foot, 0.2)
      circle(d=cleat_diameter);
                
    channel_offset = cleat_diameter/2 + string_diameter/2 - string_channel_depth;
            
    // Curved string channels which goes almost all the way around.
    rotate([0, 0, 0])
      translate([0, 0, cam_thickness/2])
        rotate_extrude(angle=360)
          translate([channel_offset, 0, 0])
            circle(string_diameter/2);
  }
  
  // Square off the ends which contact the cam.
  translate([-cleat_diameter, -cleat_diameter/2, 0]) {
    extrude_and_chamfer(cam_lip, foot)
      square([cleat_diameter, cleat_diameter]);
    translate([0, 0, cam_thickness-cam_lip])
      extrude_and_chamfer(cam_lip, 0, 0.2)
        square([cleat_diameter, cleat_diameter]);
  }
}

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
        
    channel_offset = cam_diameter/2 + string_diameter/2 - string_channel_depth;
        
    // Straight string channels on sides.
    for (a = [-1, 1])
      scale([1, a, 1])
        translate([-cam_diameter/2, channel_offset, cam_thickness/2])
          rotate([0, 90, 0])
            linear_extrude(cam_length)
              circle(string_diameter/2);
    
    // Curved string channels on ends.
    translate([cam_length/2-cam_diameter/2, 0, 0])
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([cam_diameter/2-cam_length/2, 0, cam_thickness/2])
            rotate([0, 0, 90])
              rotate_extrude(angle=180)
                translate([channel_offset, 0, 0])
                  circle(string_diameter/2);
  }
  
  // Offset the cleat so that it maintains the same string offset as it rotates.
  cleat_offset = cam_diameter/2 + cleat_diameter/2 + string_diameter - 2*string_channel_depth;
    translate([cleat_offset, cleat_offset, 0])
      rotate([0, 0, 90])
        cleat();
}

// Need beefy tubes because they have fewer reinforcing struts.
tube_wall = 4;

// Extension of roller into walls at its ends.
roller_end = 2;

// Make the tubes slightly closer.
tube_nudge = 2;

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

module limb() {
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

limb();