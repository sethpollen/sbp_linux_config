include <barrel.scad>
include <common.scad>

bolt_diameter = main_bore - extra_loose;
bolt_length = 70;
bolt_chamfer = 0.7;

// This need not extend very far into the slots. Just enough to keep the bolt from
// rotating.
rail_width = barrel_width - 4.5;
rail_height = barrel_gap - extra_loose;

tunnel_id = string_diameter + 1;

hook_height = 7.5;
hook_width = 5;
hook_opening = 5;

catch_link_length = 6;

catch_height = hook_opening - 1;
catch_block_width = 14;
catch_block_length = 5;

module catch_2d() {
  arm_thickness = 5;
  arm_length = 14;
  
  spring_thickness = 2.2;
  spring_length = 20;
  
  separation = 0.4;
  
  // Front: Hooks and thick, inflexible arms.
  difference() {
    translate([0, -hook_width/2 - arm_thickness])
      square([arm_length, hook_width + arm_thickness*2]);
    
    // Beveled front of hooked ends.
    translate([arm_length, 0])
      rotate([0, 0, 45])
        square(hook_width/sqrt(2), center=true);
    
    // Gap between arms.
    translate([-hook_width/2 - 1, -hook_width/2])
      square([arm_length, hook_width]);
    
    // Small gap between the hooked ends.
    square([50, 1], center=true);
  }
  
  // Springy arms that angle inwards.
  difference() {
    hull() {
      square([eps, hook_width + 2*arm_thickness], center=true);
      translate([-catch_link_length, 0])
        square([eps, 2*spring_thickness + separation*2], center=true);
    }
    hull() {
      translate([eps, 0])
        square([eps, hook_width], center=true);
      translate([-catch_link_length-eps, 0])
        square([eps, separation], center=true);
    }
  }
  
  // Parallel springy arms.
  translate([-catch_link_length, 0]) {
    difference() {
      hull() {
        // These arms are very slightly tapered to help the infill work out nicely
        // around the joint.
        square([eps, 2*spring_thickness + separation*2], center=true);
        translate([-spring_length, 0])
          square([eps, 2*spring_thickness + separation], center=true);
      }
      translate([-spring_length/2, 0])
        square([spring_length + 2*eps, separation], center=true);
    }
  }
  
  // Block joining the two arms.
  translate([-catch_link_length-spring_length-catch_block_length/2, 0])
    square([catch_block_length, catch_block_width], center=true);
  
  // Relieve stress at the junction by joining the arms together.
  translate([-catch_link_length-spring_length, 0])
    square([1.6, 1.6], center=true);
}

module catch() {
  linear_extrude(0.2)
    offset(-foot)
      catch_2d();
  
  translate([0, 0, 0.2])
    linear_extrude(catch_height - 0.2)
      catch_2d();
}

module bolt_body() {
  $fa = 5;
  
  intersection() {    
    // Cut off the top of the bolt to make sure it doesn't catch the next
    // dart when it slides past at high speed.
    translate([0, 1.5, (bolt_length+hook_height)/2])
      cube([bolt_diameter, bolt_diameter, bolt_length+hook_height], center=true);
    
    union() {
      flare_cylinder(bolt_length, bolt_diameter/2, bolt_chamfer, bolt_chamfer);
      
      intersection() {
        flare_cylinder(bolt_length+hook_height, bolt_diameter/2, bolt_chamfer, bolt_chamfer);

        translate([-hook_width/2, -bolt_diameter, 0])
          chamfered_cube([hook_width, 2*bolt_diameter, bolt_length+hook_height], 1.8);
      }
    }
  }

  // Rail which rides between the barrel pieces.
  hull() {
    cube([rail_width - 2*bolt_chamfer, rail_height - 2*bolt_chamfer, eps], center=true);
    translate([0, 0, bolt_chamfer])
      cube([rail_width, rail_height, eps], center=true);
    translate([0, 0, bolt_length-bolt_chamfer])
      cube([rail_width, rail_height, eps], center=true);
    translate([0, 0, bolt_length])
      cube([rail_width - 2*bolt_chamfer, rail_height - 2*bolt_chamfer, eps], center=true);
  }
}

module bolt() {
  difference() {
    bolt_body();
    
    // String tunnel.
    translate([-rail_width/2-eps, 0, tunnel_id/2 + 2.5])
      rotate([0, 90, 0])
        linear_extrude(rail_width+2*eps)
          octagon(tunnel_id);
    
    // Hook opening.
    translate([0, 0, bolt_length + hook_opening/2])
      cube([hook_width+eps, hook_opening, hook_opening], center=true);
  }
}

wedge_block_length = 5;

// A profile of a wedge to drive apart the arms of the catch.
module wedge_2d() {
  wedge_block_length = 5;
  
  difference() {
    polygon([
      [-hook_width/2, 0],
      [-hook_width/2, -wedge_block_length],
      [hook_width/2, -wedge_block_length],
      [hook_width/2, 0],
      [0, catch_link_length-0],
    ]);
    
    // Chop off the tip to avoid it being too sharp.
    translate([0, catch_link_length])
      square(1, center=true);
  }
}
