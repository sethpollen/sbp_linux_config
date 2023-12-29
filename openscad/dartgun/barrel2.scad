include <common.scad>

barrel_width = 28;
barrel_height = 35;

// In my early prints this was 4, but there was still some dart mangling.
// The theoretical limit here is probably about 3.
barrel_gap = 3.4;

main_bore = 13.8;
constricted_bore = main_bore - 0.5;
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

stroke = 80; // TODO: 120

// Allow this much extension beyond the actual firing stroke.
over_stroke = 2;

barrel_back_wall = 20; // TODO: 50
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

module bore(constriction) {
  // The bore needs to fit the dart nicely.
  $fn = 70;
  
  diam = constriction ? constricted_bore : main_bore;
  circle(d = diam);
  
  // Ensure nice bridging if we print the bore cavity facing down.
  square([2.4, diam], center=true);

  if (constriction) {
    intersection() {
      circle(d=main_bore);
      hull() {
        a = 45;
        square(constricted_bore * [cos(a), sin(a)], center=true);
        square([constricted_bore * (cos(a) + 1.2*sin(a)), eps], center=true);
      }
    }
  }
}

module barrel_2d(feed_cut=false, trunnion=false, trigger_cavity=false, constriction=false) {
  width = barrel_width + (trunnion ? trunnion_width*2 : 0);
  
  difference() {
    translate([0, bore_offset])
      square([width, barrel_height], center=true);
    
    bore(constriction);

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

module bore_top_2d(constriction=false) {
  difference() {
    translate([-bore_top_width/2, 0])
      square([bore_top_width, main_bore*0.8]);
    bore(constriction);
  }
}

module control_bar_template_2d(trunnion=false) {
  difference() {
    translate([
      bore_top_width/2 + control_bar_width/2,
      barrel_gap/2 + control_bar_height/2
    ])
      square([control_bar_width - snug, control_bar_height - snug], center=true);
    
    bore();
  }
  
  if (trunnion)
    translate([barrel_width/2 - 1, barrel_gap/2 + snug/2])
      square([trunnion_width + 1, control_bar_height - snug]);
}

module control_bar_2d(trunnion=false) {
  difference() {
    control_bar_template_2d(trunnion);
    
    // Feed cut.
    translate([0, barrel_height/2])
      square([main_bore, barrel_height], center=true);
    
    // Chamfers for printing.
    for (x = [main_bore/2, barrel_width/2 + (trunnion ? trunnion_width : 0)])
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

module enclosure_2d(trunnion=false, filled=false) {
  difference() {
    translate([0, bore_offset])
      square([barrel_width, barrel_height] + 2*enclosure_wall*[1, 1], center=true);
    
    if (!filled) {
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
}

module intrusion(length) {
  chamfer = 0.6;
  for (a = [-1, 1]) {
    scale([a, 1, 1]) {
      hull() {
        for (z = [0, length])
          translate([0, 0, z])
            linear_extrude(eps)
              offset(-chamfer)
                intrusion_2d();
        
        translate([0, 0, chamfer])
          linear_extrude(length - 2*chamfer)
            intrusion_2d();
      }
    }
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
  
  constriction_length = 3;
  translate([0, 0, barrel_back_wall + feed_cut_length]) {
    linear_extrude(constriction_length) {
      barrel_2d(constriction=true);
      bore_top_2d(constriction=true);
    }
  }

  translate([0, 0, barrel_back_wall + feed_cut_length + constriction_length]) {
    linear_extrude(stroke + over_stroke + barrel_front_wall - constriction_length) {
      barrel_2d();
      bore_top_2d();
    }
  }
  
  // Bridge at the very back, below the trigger.
  hull() {
    translate([-trigger_cavity_width/2 - 1, -barrel_height/2 + bore_offset, 0])
      cube([trigger_cavity_width + 2, 4.8, 1]);
    translate([-trigger_cavity_width/2 - 1, -barrel_height/2 + bore_offset, barrel_back_wall/2])
      cube([trigger_cavity_width + 2, 1, eps]);
  }
}

control_bar_trunnion_gap = 5;

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
  
  // Trunnions.
  for (z = [0, control_bar_trunnion_gap + trunnion_length])
    translate([0, 0, barrel_back_wall + stroke + z])
      linear_extrude(trunnion_length)
        control_bar_2d(trunnion=true);
  
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

module barrel_bottom_print() {
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

module barrel_top_print() {
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

module control_bar_print() {
  rotate([0, 0, 45]) {
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        translate([0, 0, barrel_gap/2 + control_bar_height - 0.1])
          rotate([-90, 0, 0])
            control_bar();
        
        linear_extrude(0.4)
          for (x = [barrel_width/2, bore_top_width/2], y = [0, total_barrel_length])
            translate([x, y])
              octagon(10);
      }
    }
  }
}

// TODO: Stuff below is temporary, just for doing a test print of
// the control mechanism.

module front_slide() {
  length = 26;
  
  difference() {
    linear_extrude(length) {
      difference() {
        enclosure_2d();
        
        // Chop off the ceiling.
        translate([-barrel_width/2 + 2, bore_offset + barrel_height/2])
          square([barrel_width - 4, enclosure_wall]);
      }
    }
    
    // Trunnion holes.
    for (z = [0, control_bar_trunnion_gap + trunnion_length])
      translate([0, barrel_gap/2 + control_bar_height/2, trunnion_length/2 + z])
        cube([
          barrel_width + trunnion_width*2 + 1,
          control_bar_height + snug,
          trunnion_length + loose
        ], center=true);
  }
    
  intrusion(length);
}

mag_height = 50;

module back_slide() {
  length = barrel_back_wall;
  
  linear_extrude(trunnion_length + snug)
    enclosure_2d(trunnion=true);
  
  translate([0, 0, trunnion_length + snug])
    linear_extrude(length - trunnion_length - snug)
      enclosure_2d();
  
  intrusion(length);
  
  difference() {
    union() {
      translate([-(main_bore+8)/2, barrel_height/2 + bore_offset + 0.15, 0])
        cube([main_bore+8, mag_height, barrel_back_wall + feed_cut_length + 4]);
      translate([-(main_bore+20)/2, barrel_height/2 + bore_offset + mag_height/2, 0])
        cube([main_bore+20, 3, barrel_back_wall + feed_cut_length + 4]);
    }
    translate([-main_bore/2, barrel_height/2 + bore_offset + 0.15 - eps, barrel_back_wall + eps])
      cube([main_bore, mag_height + 2*eps, feed_cut_length]);
  }
}

module follower_2d() {
  translate([-3, -2])
    square([3, feed_cut_length + 4]);
  
  translate([0, extra_loose/2]) {
    square([mag_height, feed_cut_length - 0.6]);
  
    translate([mag_height, 0])
      square([8, feed_cut_length - 1.6]);
  }
}

module follower() {
  linear_extrude(0.2)
    offset(-0.3)
      follower_2d();
  
  difference() {
    translate([0, 0, 0.2])
      linear_extrude(main_bore - 1.8)
        follower_2d();
    
    translate([-102, 20, 1])
      rotate([90, 0, 90])
        linear_extrude(100)
          text("→", main_bore * 1.6);
  }
}

module preview() {
  x = 80;
  back_slide();
  barrel();
  translate([0, 0, x]) {
    translate([0, 0, -stroke])
      control_bar();
    translate([0, 0, barrel_back_wall])
      front_slide();
  }
}


rotate([-90, 0, 0])
intersection() {
  union() {
    linear_extrude(5)
      barrel_2d();
    translate([0, 0, 5])
      linear_extrude(5)
        barrel_2d(constriction=true);
    translate([0, 0, 10])
      linear_extrude(5)
        barrel_2d();
  }
  translate([-50, -100, 0])
    cube(100);
}
