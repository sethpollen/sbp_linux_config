include <common.scad>
include <barrel2.scad>
include <link.scad>
 
receiver_length = 100;
trigger_pivot_diameter = 6;
trigger_pivot_x = 3;
trigger_pivot_y = (71-receiver_length)/2;
grip_length = 52;
grip_height = 85;
trigger_length = 45;

module grip() {
  circle_diameter = slider_width*1.2;
  
  intersection() {
    hull() {
      for (y = (grip_length/2 - circle_diameter/2) * [-1, 1]) {
        translate([0, y + grip_height*0.4, 0])
          linear_extrude(eps)
            circle(circle_diameter/2-2);
        translate([0, y + grip_height*0.4, 2])
          linear_extrude(eps)
            circle(circle_diameter/2);
        translate([0, y, grip_height])
          sphere(circle_diameter/2);
      }
    }
      
    translate([-slider_width/2, -100, 0])
      cube([slider_width/2, 200, grip_height + circle_diameter/2]);
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
              slider(receiver_length, slot=receiver_length-lug_offset, zip_channels=[23.5]);
          
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
       
      // Grip.
      translate([grip_height + slider_height/2, (165-receiver_length)/2, 0])
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
          square([slider_height/2 + 12, receiver_length - trigger_cavity_y - 41.2 + 2*eps]);
          square([slider_height/2 + 5, receiver_length - trigger_cavity_y - 15 + 2*eps]);
        }
      }
    }
    
    // Hollow in front to fit over the string in the collapsed position, so that the two
    // sliders can touch even with the string between them.
    translate([0, -receiver_length/2, -20])
      linear_extrude(20)
        octagon(9);
  }
  
  translate([0, 0, -trigger_cavity_width/2]) {
    linear_extrude(trigger_cavity_width/2) {
      // Trigger pivot post.
      translate([trigger_pivot_x, trigger_pivot_y])
        circle(d=trigger_pivot_diameter);
      
      // Rubber band posts.
      for (xy = [
        [2, 30],
        [8, 30],
        [14, 30],
        [20, 30],
        [23, 25],
        [23, 18],
        [23, 11],
      ])
        translate(xy)
          circle(1.5);
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
          translate([0, trigger_width/2 - 4])
            square([ring_diameter, trigger_offset + 4]);
        }
        
        // Forward stop.
        stop_length = 16;
        stop_thickness = 4;
        translate([0, -7.69])
          square([stop_length, stop_thickness]);
      }
      
      // Main rod.
      hull() {
        translate([0, -rod_length]) {
          square([5, rod_length]);
          translate([0, -8])
            square(eps);
        }
      }
      
      // Trigger.
      trigger_offset = 18;
      rotate([0, 0, -10]) {
        translate([0, trigger_offset-trigger_width/2])
          square([trigger_length, trigger_width]);
        translate([trigger_length, trigger_offset])
          circle(d=trigger_width);
      }
    }
    circle(d=trigger_pivot_diameter + extra_loose);
  }
    
  // String catch.
  catch_round = 3;
  hull() {
    translate([1, -rod_length]) {
      circle(d=catch_round);
      translate([0, -10+catch_round/2])
        circle(d=catch_round);
      
      translate([-barrel_gap/2 - catch_round/2 - 1, 0])
        circle(d=catch_round);
    }
  }
}

module trigger() {
  difference() {
    union() {
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
    }
  
    // Slot for rubber band.
    translate([5, 19.5, -1]) {
      difference() {
        linear_extrude(trigger_width/2 + 1 + eps)
          rotate([0, 0, -65])
            square([13, 30], center=true);
        linear_extrude(trigger_width/2 + 1 + eps, scale=1.4)
          circle(d=5);
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

preview();
