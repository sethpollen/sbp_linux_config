include <common.scad>
include <barrel2.scad>
include <link.scad>
 

receiver_length = 90;
trigger_pivot_diameter = 6;
spring_anchor_diameter = 4.5;

module receiver() {
  lug_offset = 25;
  trigger_cavity_y = lug_offset + barrel_lug_y/2 + 0.3;

  difference() {
    union() {
      intersection() {
        union() {
          translate([0, 0, 0])
            rotate([0, 90, 0])
              slider(receiver_length, slot=receiver_length-lug_offset);
          
          translate([slider_height/2, -receiver_length/2 + main_diameter/2, 0])
            rotate([0, -90, 0])
              link_anchor(enclosure_thickness=10, spread=2.1);
        }
        
        // Remove the top half.
        translate([0, 0, -slider_width/4])
          cube([100, receiver_length, slider_width/2], center=true);
      }
      
      // Wall of trigger chamber.
      translate([-1, trigger_cavity_y - receiver_length/2, -slider_width/2])
        cube([slider_height/2 + 1, receiver_length - trigger_cavity_y, slider_width/2]);
    }
    
    // Trigger slot.
    translate([-1 - eps, trigger_cavity_y - receiver_length/2 - eps, -trigger_cavity_width/2 - eps])
      cube([slider_height/2 + 1 + 2*eps, receiver_length - trigger_cavity_y + 2*eps, trigger_cavity_width + 2*eps]);
    
    // Hollow in front to fit over the string in the collapsed position, so that the two
    // sliders can touch even with the string between them.
    translate([0, -receiver_length/2, -20])
      linear_extrude(20)
        octagon(9);
    
    // Angle the back of the receiver where the top rail will protrude in the collapsed position.
    translate([-60, 60, -20])
      linear_extrude(21)
        rotate([0, 0, 40])
          square(120, center=true);
  }
}

module trigger_2d() {  
  rod_length = 40;

  // Pivot.
  difference() {
    $fn = 40;
    union() {
      circle(d=trigger_pivot_diameter+9);
      
      // Main rod.
      hull() {
        translate([-7, -rod_length]) {
          square([5, rod_length]);
          translate([0, -8])
            square(eps);
        }
      }
      
      // Trigger.
      trigger_length = 45;
      trigger_offset = 18;
      rotate([0, 0, -10]) {
        translate([0, trigger_offset-trigger_width/2])
          square([trigger_length, trigger_width]);
        translate([-0.5, trigger_width/2 - 4])
          square([trigger_width, trigger_offset + 4]);
        translate([trigger_length, trigger_offset])
          circle(d=trigger_width);
      }
    }
    circle(d=trigger_pivot_diameter + extra_loose);
  }
    
  // String catch.
  catch_round = 3;
  hull() {
    translate([-6, -rod_length]) {
      circle(d=catch_round);
      translate([0, -10+catch_round/2])
        circle(d=catch_round);
      
      translate([-barrel_gap/2 - catch_round/2 - 1, 0])
        circle(d=catch_round);
    }
  }
}

module trigger() {
  // Unchamfered part.
  translate([0, 0, -trigger_width/2+1.2])
    linear_extrude(trigger_width-2.4)
      trigger_2d();
  
  // Chamfers.
  for (a = [-1, 1], b = [0:0.2:1])
    scale([1, 1, a])
      translate([0, 0, -trigger_width/2+b])
        linear_extrude(0.2)
          offset(b-1.2 - (a == 1 && b == 0 ? 0.2 : 0))
            trigger_2d();

  // Spring arm.
  spring_arm_length = 13;
  translate([0, 0, -trigger_width/2]) {
    rotate([0, 0, 35]) {
      translate([-2, 4])
        cube([4, spring_arm_length, trigger_width/2-0.5]);
      translate([0, 4+spring_arm_length])
        cylinder(h=trigger_width, d=spring_anchor_diameter);
    }
  }
}

module preview() {
  receiver();
  translate([9, -9.5, 0])
    trigger();
}

preview();
