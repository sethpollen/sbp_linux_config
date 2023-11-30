include <common.scad>
include <barrel2.scad>
include <link.scad>
 
receiver_length = 95;
trigger_pivot_diameter = 6;
trigger_pivot_x = 3;
trigger_pivot_y = (71-receiver_length)/2;
grip_length = 53;
grip_height = 85;

module grip() {
  circle_diameter = slider_width*1.2;
  
  difference() {
    intersection() {
      hull() {
        for (y = (grip_length/2 - circle_diameter/2) * [-1, 1]) {
          translate([0, y + grip_height*0.25, 0])
            linear_extrude(eps)
              circle(circle_diameter/2-2);
          translate([0, y + grip_height*0.25, 2])
            linear_extrude(eps)
              circle(circle_diameter/2);
          translate([0, y, grip_height])
            sphere(circle_diameter/2);
        }
      }
        
      translate([-slider_width/2, -100, 0])
        cube([slider_width/2, 200, grip_height + circle_diameter/2]);
    }
    
    hull() {
      for (y = (grip_length/2 - circle_diameter/2 + 2) * [-1, 1]) {
        translate([0, y, -eps]) {
          translate([0, grip_height*0.25, 0])
            linear_extrude(eps)
              circle(d=circle_diameter-18);
          translate([0, grip_height*0.04, grip_height - 10])
            linear_extrude(eps)
              circle(d=circle_diameter-18);
        }
      }
    }
  }
}

module receiver() {
  lug_offset = 25;
  trigger_cavity_y = lug_offset + barrel_lug_y/2 + 0.3;

  difference() {
    union() {
      intersection() {
        union() {
          translate([0, 0, 0])
            rotate([0, 90, 0])
              slider(receiver_length, slot=receiver_length-lug_offset, zip_channels=[34]);
          
          translate([slider_height/2, -receiver_length/2 + main_diameter/2, 0])
            rotate([0, -90, 0])
              link_anchor(enclosure_thickness=10, spread=2.1);
        }
        
        // Remove the top half.
        translate([0, 0, -slider_width/4])
          cube([100, receiver_length, slider_width/2], center=true);
      }
      
      // Wall of trigger chamber.
      translate([-1, trigger_cavity_y - receiver_length/2, -barrel_width/2-1])
        cube([barrel_height/2 + 2, receiver_length - trigger_cavity_y, barrel_width/2+1]);
       
      // Grip.
      translate([grip_height + slider_height/2, (155-receiver_length)/2 + 0.5, 0])
        rotate([0, -90, 0])
          grip();
    }
    
    // Angle the back of the receiver.
    translate([-30, 18, -slider_width/2 - eps])
      rotate([0, 0, 45])
        cube([50, 30, slider_width]);

    // Trigger slot.
    translate([-1 - eps, trigger_cavity_y - receiver_length/2 - eps, -trigger_cavity_width/2 - eps]) {
      linear_extrude(trigger_cavity_width/2 + 2*eps) {
        union() {
          square([slider_height/2 + 12, receiver_length - trigger_cavity_y - (receiver_length - 53.7) + 2*eps]);
          square([slider_height/2 + 5, receiver_length - trigger_cavity_y - (receiver_length - 85) + 2*eps]);
        }
      }
    }
    
    // Hollow in front to fit over the string in the collapsed position, so that the two
    // sliders can touch even with the string between them.
    translate([0, -receiver_length/2, -20])
      linear_extrude(20)
        octagon(9);
    
    // Slight cutout to strengthen the connection of the pivot pin against shearing.
    translate([trigger_pivot_x, trigger_pivot_y, -trigger_cavity_width/2 - 2])
      linear_extrude(10)
        circle(d=trigger_pivot_diameter-3.5);
  }
  
  translate([0, 0, -trigger_cavity_width/2]) {
    linear_extrude(trigger_cavity_width/2) {
      // Trigger pivot post.
      translate([trigger_pivot_x, trigger_pivot_y]) {
        difference() {
          circle(d=trigger_pivot_diameter);
          circle(d=trigger_pivot_diameter-3.5);
        }
      }
      
      // Rubber band posts.
      for (xy = [
        [2, 33],
        [8, 33],
        [14, 33],
        [20, 33],
        [23, 28],
        [23, 21],
        [23, 14],
      ])
        translate(xy)
          circle(1.5);
    }
  }
  
  // Print aids.
  translate([0, 0, -slider_width/2]) {
    linear_extrude(0.4) {
      translate([-slider_height/2 + 5.5, -receiver_length/2 - 5])
        square(10, center=true);
      translate([-slider_height/2 - 5, -receiver_length/2 + 5.5])
        square(10, center=true);
      translate([grip_height + slider_height/2 + 5, 54])
        square([10, 20], center=true);
    }
  }
}

module trigger_2d() {  
  rod_length = 40;
  ring_diameter = trigger_pivot_diameter+9;

  // Pivot.
  difference() {
    $fn = 40;
    union() {
      hull() {
        circle(d=ring_diameter);
        
        rotate([0, 0, -10]) {
          translate([-5, trigger_width/2 - 4])
            square([ring_diameter + 5, trigger_offset + 4]);
        }
        
        // Forward stop.
        stop_length = 16;
        stop_thickness = 4;
        translate([0, -7.69])
          square([stop_length, stop_thickness]);
      }
      
      // Main rod.
      hull() {
        // Slightly thicken the rod where it joins the pivot.
        square([7, eps]);

        translate([0, -rod_length]) {
          square([5, rod_length]);
          translate([1, -10])
            square(eps);
        }
      }
      
      // Trigger.
      trigger_offset = 14;
      rotate([0, 0, -10]) {
        translate([10, trigger_offset]) {
          offset(r=trigger_width/2) {
            intersection() {
              // Limit the arc with a box.
              trigger_length = 30;
              translate([0, -10])
                square([trigger_length, 20]);
              
              // Arc.
              arc_radius = 90;
              translate([7, -arc_radius]) {
                difference() {
                  $fn = 90;
                  circle(arc_radius);
                  circle(arc_radius-0.01);
                }
              }
            }
          }
        }
      }
    }
  }
    
  // String catch.
  catch_round = 3;
  catch_top_x = -barrel_gap/2 - catch_round - 1;
  difference() {
    hull() {
      translate([1, -rod_length]) {
        circle(d=catch_round);
        
        translate([0, -10+catch_round/2])
          circle(d=catch_round);
        
        translate([catch_top_x, 0])
          circle(d=catch_round);
      }
    }
    
    // Make the holding face slightly concave, so that the string doesn't
    // torque the trigger when under tension.
    circle(norm([rod_length, 1+catch_top_x]) - catch_round/2, $fn=180);
  }
}

// Print with 40% cubic infill.
module trigger() {
  difference() {
    union() {
      // Unchamfered part.
      translate([0, 0, -trigger_width/2+1.2])
        linear_extrude(trigger_width-2.4)
          trigger_2d();
      
      // Chamfers. Use big chamfers for two reasons:
      //   1. It helps the string slide off the catch.
      //   2. It makes the trigger feel nice.
      for (a = [-1, 1], b = [0:0.2:1])
        scale([1, 1, a])
          translate([0, 0, -trigger_width/2+b])
            linear_extrude(0.2)
              offset(b-1.2 - (a == 1 && b == 0 ? 0.2 : 0))
                trigger_2d();
    }
  
    // Slot for rubber band.
    translate([-0.5, 16.5, -1]) {
      difference() {
        linear_extrude(trigger_width)
          rotate([0, 0, -65])
            square([13, 30], center=true);
        linear_extrude(trigger_width/2 + 1 + eps, scale=1.4)
          circle(d=5);
      }
    }
    
    // Cut out the pivot hole, with just enough chamfer to prevent elephant foot.
    pivot_hole_diameter = trigger_pivot_diameter + extra_loose;
    for (a = [-1, 1]) {
      scale([1, 1, a]) {
        translate([0, 0, -trigger_width/2-eps]) {
          cylinder(trigger_width, d=pivot_hole_diameter);
          cylinder(0.5, d1=pivot_hole_diameter+1, d2=pivot_hole_diameter);
        }
      }
    }
  }
}

module preview(pulled=false) {
  receiver();
  translate([trigger_pivot_x, trigger_pivot_y, 0])
    rotate([0, 0, pulled ? 11 : 0])
      trigger();
}

preview(true);