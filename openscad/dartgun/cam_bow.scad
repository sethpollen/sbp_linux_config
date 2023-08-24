include <common.scad>
include <../extrude_and_chamfer.scad>
include <../morph.scad>

cam_lip = 1.5;
cam_thickness = string_diameter + 2*cam_lip;
cam_cavity_diameter = cam_thickness + extra_loose;
cam_diameter = 18;
cam_length = 45;

cleat_diameter = 7;

string_channel_depth = string_diameter * 0.35;

module cam_2d() {
  // The back of the cam, which has a simple shape and faces away from you.
  // This part houses the serpentine channel for retaining the string.
  hull() {
    intersection() {
      for (x = [0, cam_length - cam_diameter])
        translate([x, 0, 0])
          circle(d=cam_diameter);
      translate([-cam_diameter/2, -cam_length, 0])
        square(cam_length);
    }
  }
  
  // The front of the cam, which has a gradual increase in radius (like
  // most cams.
  polygon([
    for (a = [0 : 1/30 : 1])
      min(
        // Keep the short side flat.
        a < 0.4 ? (cam_diameter/2 / cos(a * 180)) : 1000,
        (cam_diameter/2 + (0.5 - 0.5 * cos(a * 180)) * (cam_length - cam_diameter))
      )
      * [-cos(a*180), sin(a*180)]
  ]);
}

module make_cam_exterior() {
  // Exterior, with an octagonal groove for the string.
  groove_chamfer = string_diameter*0.4;
  morph([
    [0, [0]],
    [cam_lip, [0]],
    [cam_lip + groove_chamfer, [groove_chamfer]],
    [cam_thickness - cam_lip - groove_chamfer, [groove_chamfer]],
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
      translate([cam_diameter/2 + string_diameter/2, -cam_diameter/2-cleat_diameter/2, 0]) {
        make_cam_exterior()
          circle(d=cleat_diameter);
      
        // Plates joining cleat to cam.
        for (z = [0, cam_thickness - cam_lip])
          translate([-cleat_diameter/2, 0, z])
            cube([cleat_diameter, cleat_diameter, cam_lip]);
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

cam();

