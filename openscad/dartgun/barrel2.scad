include <common.scad>

// TODO: more? the bars along the feed cut are kinda thin
barrel_width = 28;
barrel_height = 38;

// In my early prints this was 4, but there was still some dart mangling.
// The theoretical limit here is probably about 3.
barrel_gap = 3.4;

main_bore = 13.8;
barrel_intrusion = (barrel_width - main_bore) / 2 - 1;

// Width of the rail which forms the top of the bore.
bore_top_width = 6;

// TODO: use bore_top_width instead of using this
control_bar_width = (barrel_width - bore_top_width) / 2;
control_bar_height = 7.4;

trunnion_width = 3;
trunnion_length = 5;

// TODO: trigger channel

module bore() {
  // The bore needs to fit the dart nicely.
  $fn = 70;
  circle(d=main_bore);
}

module barrel_2d(feed_cut=false, trunnion=false) {
  difference() {
    square(
      [barrel_width + (trunnion ? trunnion_width*2 : 0), barrel_height],
      center=true
    );
    
    bore();

    // Gap for string and control bars.
    translate([-barrel_width/2 - trunnion_width - eps, -barrel_gap/2])
      square([barrel_width + trunnion_width*2 + 1, barrel_gap + control_bar_height]);
    
    if (feed_cut)
      translate([0, barrel_height/2])
        square([main_bore, barrel_height], center=true);
  }
}

module bore_top_2d() {
  difference() {
    translate([-bore_top_width/2, 0])
      square([bore_top_width, barrel_height/4]);
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
        rotate([0, 0, 45])
          square(1, center=true);
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
  translate([barrel_width/2 - barrel_intrusion/2, 0])
    square([barrel_intrusion, barrel_gap - snug], center=true);
}

stroke = 120;
barrel_back_wall = 30;
feed_cut_length = 74;

module barrel() {
  feed_ramp_length = 5;

  linear_extrude(trunnion_length) {
    barrel_2d(trunnion=true);
    bore_top_2d();
  }
  
  translate([0, 0, trunnion_length]) {
    linear_extrude(barrel_back_wall - trunnion_length) {
      barrel_2d();
      bore_top_2d();
    }
  }
  
  translate([0, 0, barrel_back_wall])
    linear_extrude(feed_cut_length)
      barrel_2d(true);
  
  translate([0, 0, barrel_back_wall + feed_cut_length]) {
    linear_extrude(stroke)
      barrel_2d();
    
    minkowski() {
      linear_extrude(eps)
        bore_top_2d();
      
      feed_ramp_height = 3;
      hull() {
        translate([0, feed_ramp_height, 0])
          cube(eps);
        translate([0, 0, feed_ramp_length])
          cube([eps, feed_ramp_height, stroke - feed_ramp_length]);
      }
    }
  }
}

module control_bar() {
  feed_ramp_length = 15;

  linear_extrude(barrel_back_wall + stroke - feed_ramp_length) {
    control_bar_2d();
    control_bar_bore_2d();
  }
  
  translate([0, 0, barrel_back_wall + stroke - feed_ramp_length]) {
    linear_extrude(feed_ramp_length)
      control_bar_2d();
    
    feed_ramp_width = 4;
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
    linear_extrude(feed_cut_length)
      control_bar_2d();
}

barrel();
control_bar();

