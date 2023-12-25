include <common.scad>

barrel_width = 28;
barrel_height = 35;

// In my early prints this was 4, but there was still some dart mangling.
// The theoretical limit here is probably about 3.
barrel_gap = 3.4;

main_bore = 13.8;
barrel_intrusion = (barrel_width - main_bore) / 2 - 2;

// Width of the rail which forms the top of the bore.
bore_top_width = 6;

// Vertical offset of the bore within the barrel's rectangle. We push
// the bore down slightly to thicken up the top barrel, which is
// naturally too thin because of the control bar cavities.
bore_offset = 3.5;

control_bar_width = (barrel_width - bore_top_width) / 2;
control_bar_height = 7.4;

trunnion_width = 3;
trunnion_length = 5;

stroke = 120;

// Allow this much extension beyond the actual firing stroke.
over_stroke = 2;

barrel_back_wall = 50;
feed_cut_length = 74;
barrel_front_wall = 10;

total_barrel_length = stroke + over_stroke + barrel_back_wall + feed_cut_length + barrel_front_wall;

enclosure_wall = 7;

trigger_width = 8;
trigger_cavity_width = trigger_width + extra_loose;

module print_chamfer() {
  rotate([0, 0, 45])
    square(0.7, center=true);
}

module bore() {
  // The bore needs to fit the dart nicely.
  $fn = 70;
  circle(d=main_bore);
}

module barrel_2d(feed_cut=false, trunnion=false, trigger_cavity=false) {
  width = barrel_width + (trunnion ? trunnion_width*2 : 0);
  
  difference() {
    translate([0, bore_offset])
      square([width, barrel_height], center=true);
    
    bore();

    // Chamfers for printing.
    for (x = width/2 * [-1, 1], y = barrel_height/2 * [-1, 1])
      translate([x, y + bore_offset])
        print_chamfer();    

    // Gap for string and control bars.
    translate([-barrel_width/2 - eps, -barrel_gap/2])
      square([barrel_width + 2*eps, barrel_gap + control_bar_height]);
    
    // Extend part of the gap through the trunnions.
    translate([-barrel_width/2 - trunnion_width - eps, -barrel_gap/2])
      square([barrel_width + 2*eps + 2*trunnion_width, barrel_gap]);
    
    if (feed_cut) {
      translate([0, barrel_height/2])
        square([main_bore, barrel_height], center=true);
      
      for (x = main_bore/2 * [-1, 1])
        translate([x, barrel_height/2 + bore_offset])
          print_chamfer();
    }
    
    if (trigger_cavity) {
      translate([0, -barrel_height/2 + bore_offset])
        square([trigger_cavity_width, barrel_height], center=true);

      for (x = trigger_cavity_width/2 * [-1, 1])
        translate([x, -barrel_height/2 + bore_offset])
          print_chamfer();
    }
  }
}

module bore_top_2d() {
  difference() {
    translate([-bore_top_width/2, 0])
      square([bore_top_width, main_bore*0.8]);
    bore();
  }
}

module control_bar_template_2d() {
  difference() {
    translate([
      bore_top_width/2 + control_bar_width/2,
      barrel_gap/2 + control_bar_height/2
    ])
      square([control_bar_width - snug, control_bar_height - snug], center=true);
    
    bore();
  }
}

module control_bar_2d() {
  difference() {
    control_bar_template_2d();
    
    // Feed cut.
    translate([0, barrel_height/2])
      square([main_bore, barrel_height], center=true);
    
    // Chamfers for printing.
    for (x = [main_bore/2, barrel_width/2])
      translate([x, control_bar_height + barrel_gap/2])
        print_chamfer();
  }
}

// The part of the control bar which forms part of the bore.
module control_bar_bore_2d() {
  difference() {
    intersection() {
      control_bar_template_2d();
      
      // Add 2 to the width to fill in the chamfer in control_bar_2d.
      translate([0, barrel_height/2])
        square([main_bore + 2, barrel_height], center=true);
    }
    
    // Chamfer for nice mating with the undersight of the next dart.
    translate([bore_top_width/2, control_bar_height + barrel_gap/2])
      rotate([0, 0, 45])
        square(1.3, center=true);
  }
}

module intrusion_2d() {
  difference() {
    translate([barrel_width/2 - barrel_intrusion/2 + 2, 0])
      square([barrel_intrusion + 4, barrel_gap - snug], center=true);
    
    for (y = (barrel_gap - snug) * [-0.5, 0.5])
      translate([barrel_width/2 - barrel_intrusion, y])
        print_chamfer();
  }
}

module enclosure_2d(trunnion=false) {
  difference() {
    translate([0, bore_offset])
      square([barrel_width, barrel_height] + 2*enclosure_wall*[1, 1], center=true);
    
    translate([0, bore_offset])
      // Add 0.1 to the horizontal clearance, since we are bolting these parts
      // together tightly.
      square([
        barrel_width + loose + 0.1 + (trunnion ? 2*trunnion_width : 0),
        barrel_height + loose
      ], center=true);
    
    // Ensure good corners.
    for (
      x = (barrel_width + 0.1 + (trunnion ? 2*trunnion_width : 0))/2 * [1, -1],
      y = barrel_height/2 * [1, -1]
    )
      translate([x, y + bore_offset])
        circle(d=0.7, $fn=8);
  }
}

module barrel() {
  feed_ramp_length = 3;
  feed_ramp_height = 3;

  linear_extrude(trunnion_length) {
    barrel_2d(trunnion=true, trigger_cavity=true);
    bore_top_2d();
  }
  
  translate([0, 0, trunnion_length]) {
    linear_extrude(barrel_back_wall - trunnion_length) {
      barrel_2d(trigger_cavity=true);
      bore_top_2d();
    }
  }
  
  translate([0, 0, barrel_back_wall])
    linear_extrude(feed_cut_length)
      barrel_2d(feed_cut=true);
  
  translate([0, 0, barrel_back_wall + feed_cut_length]) {
    linear_extrude(stroke + over_stroke + barrel_front_wall)
      barrel_2d();
    
    minkowski() {
      linear_extrude(eps)
        bore_top_2d();
      
      hull() {
        translate([0, feed_ramp_height, 0])
          cube(eps);
        translate([0, 0, feed_ramp_length])
          cube([eps, feed_ramp_height, stroke + over_stroke + barrel_front_wall - feed_ramp_length]);
      }
    }
  }
  
  // Bridge at the very back, below the trigger.
  hull() {
    translate([-trigger_cavity_width/2 - 1, -barrel_height/2 + bore_offset, 0])
      cube([trigger_cavity_width + 2, 4.8, 1]);
    translate([-trigger_cavity_width/2 - 1, -barrel_height/2 + bore_offset, 25])
      cube([trigger_cavity_width + 2, 1, eps]);
  }
}

module control_bar() {
  feed_ramp_length = 15;
  feed_ramp_width = 4;

  linear_extrude(barrel_back_wall + stroke - feed_ramp_length) {
    control_bar_2d();
    control_bar_bore_2d();
  }
  
  translate([0, 0, barrel_back_wall + stroke - feed_ramp_length]) {
    linear_extrude(feed_ramp_length)
      control_bar_2d();
    
    difference() {
      minkowski() {
        linear_extrude(eps)
          control_bar_bore_2d();
        
        hull() {
          cube([feed_ramp_width, eps, eps]);
          translate([feed_ramp_width, 0, feed_ramp_length])
            cube(eps);
        }
      }
    
      // Apply a vertical chamfer as well, to slide under the next dart.
      hull() {
        translate([bore_top_width/2, barrel_gap/2 + control_bar_height, 0])
          rotate([0, 0, 45])
            cube([1.3, 1.3, eps], center=true);
        translate([bore_top_width/2 + feed_ramp_width, barrel_gap/2 + control_bar_height, feed_ramp_length])
          rotate([0, 0, 45])
            cube([4.1, 4.1, eps], center=true);
      }
    }
  }
  
  translate([0, 0, barrel_back_wall + stroke])
    linear_extrude(feed_cut_length + over_stroke)
      control_bar_2d();
  
  translate([0, 0, barrel_back_wall + stroke + feed_cut_length + over_stroke]) {
    linear_extrude(barrel_front_wall) {
      control_bar_2d();
      
      // Add a small protrusion to ride against the bore top rail. There is no
      // bore surface here; just enough to keep the control arms apart.
      intersection() {
        control_bar_bore_2d();
        translate([0, barrel_gap/2 + control_bar_height - 2.6])
          square([barrel_width/2, 2.6]);
      }
    }
  }
}

module barrel_print_aids() {
  linear_extrude(0.4) {
    for (x = (barrel_width/2 + trunnion_width) * [1, -1])
      translate([x, 0])
        octagon(10);
    for (x = (barrel_width/2) * [1, -1])
      translate([x, -total_barrel_length])
        octagon(10);
  }
}

module barrel_bottom() {
  rotate([0, 0, 45]) {
    translate([0, 0, barrel_height/2 - bore_offset]) {
      intersection() {
        rotate([90, 0, 0])
          barrel();
        
        translate([-50, -500, -50])
          cube([100, 500, 50]);
      }
    }
    barrel_print_aids();
  }
}

module barrel_top() {
  rotate([0, 0, 45]) {
    scale([1, -1, 1]) {
      translate([0, 0, barrel_height/2 + bore_offset]) {
        intersection() {
          rotate([-90, 0, 0])
            barrel();
          
          translate([-50, 0, -50])
            cube([100, 500, 50]);
        }
      }
    }
    barrel_print_aids();
  }
}

barrel_top();