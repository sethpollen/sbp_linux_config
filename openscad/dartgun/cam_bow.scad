include <common.scad>
include <../extrude_and_chamfer.scad>

cam_lip = 1;
cam_thickness = string_diameter + 2*cam_lip;
cam_cavity_diameter = cam_thickness + extra_loose;
cam_diameter = 18;
cam_length = 45;

string_channel_depth = string_diameter * 0.35;

cleat_diameter = 6;

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
    translate([0, 0, -2*eps])
      extrude_and_chamfer(cam_thickness+4*eps, -foot, -0.2)
        circle(d=roller_diameter);
        
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

cam();
