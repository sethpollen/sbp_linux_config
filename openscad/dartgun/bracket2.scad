include <common.scad>
include <barrel.scad>
include <block.scad>

nail_diameter = 3.3;
nail_loose_diameter = 3.7;
nail_snug_diameter = 3.6;

socket_diameter = 7;
spring_height = 12;
spring_hub_diameter = 15;
spring_thickness = 3;
spring_gap = 3;
spring_turns = 5;

// The distance between the centers of the two holes.
spring_hole_spacing =
  spring_hub_diameter/2 + spring_thickness/2 + (spring_thickness + spring_gap) * spring_turns + snug;

cam_thickness = 12;

bracket_plate_thickness = 5;
bracket_length = 59;
spring_cavity_height = spring_height*2 + cam_thickness + 2;

pin_hole_y = -bracket_length/2 + 5;
pin_hole_z = -nail_diameter - spring_thickness;

module bracket2() {
  body_width = spring_hole_spacing + 12;

  // Needs to be long enough to support the part during printing.
  tip_length = bracket_length/2;
  
  rib_thickness = 6;
  rib_height = 8;
    
  difference() {
    union() {
      // Block which adapts to rail.
      translate([0, 0, 2])
        block(bracket_length);
            
      // Body.
      hull() {
        translate([0, 0, 2])
          linear_extrude(eps)
            square([block_height, bracket_length], center=true);
        translate([0, tip_length/2-bracket_length/2, -body_width])
          linear_extrude(eps)
            square([block_height, tip_length], center=true);
      }
      
      // Reinforcing rib, to keep everything aligned during printing.
      translate([0, -15, 0]) {
        hull() {
          translate([0, 0, 6])
            linear_extrude(eps)
              square([block_height, rib_thickness], center=true);
          translate([0, 0, -10])
            linear_extrude(eps)
              square([block_height+2*rib_height, rib_thickness], center=true);
          translate([0, 0, -body_width])
            linear_extrude(eps)
              square([block_height+2*rib_height, rib_thickness], center=true);
        }
      }
    }
    
    // Pin holes.
    for (z = [pin_hole_z, pin_hole_z-spring_hole_spacing])
      translate([0, pin_hole_y, z])
        rotate([0, 90, 0])
          translate([0, 0, -block_height/2-2])
            linear_extrude(block_height+4)
              octagon(nail_loose_diameter);
        
    // Main spring cavity. It is composed of two blocks to leave a bridge between
    // the plates in front.
    translate([-spring_cavity_height/2, -50, -100])
      cube([spring_cavity_height, 64, 100]);
    translate([-spring_cavity_height/2, -50, -122])
      cube([spring_cavity_height, 100, 100]);
        
    // Avoid elephant foot inside the cavity.
    chamfer_side = (spring_cavity_height+2)/sqrt(2);
    translate([0, 0, -body_width])
      rotate([0, 45, 0])
        cube([chamfer_side, 100, chamfer_side], center=true);

    // Zip tie channels.
    channel_height = 2.2;
    channel_width = 6.5;
    for (y = [bracket_length/2-11, 4-bracket_length/2]) {
      translate([0, y, 2]) {
        translate([-50, 0, 0])
          cube([100, channel_width, channel_height]);
        for (b = [-1, 1])
          scale([b, 1, 1])
            translate([block_height/2 - channel_height, 0, channel_height])
              rotate([0, 45, 0])
                cube(channel_width);
      }
    }
  }
  
  // Block to keep springs separated.
  translate([-cam_thickness/2, -bracket_length/2, -0.5-spring_thickness])
    chamfered_cube([cam_thickness, 4*spring_thickness, spring_thickness+2], 0.4);
}

bracket2();