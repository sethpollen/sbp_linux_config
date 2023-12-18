barrel_width = 30;
barrel_height = 38;

barrel_intrusion = 7;
barrel_gap = 4;

main_bore = 13.8;

// TODO: get rid of the shoulder. The bars can go all the way to the sides,
// since they will always be present between a slider and the barrel.
barrel_shoulder_width = 3.5;
barrel_shoulder_height = barrel_gap/2 + 4;

control_bar_width = 8.5;
control_bar_height = 7;

$fn = 70;

module barrel_2d(feed_cut=false) {
  difference() {
    square([barrel_width, barrel_height], center=true);
    
    circle(d=main_bore);

    // Main gap for string.
    square([barrel_width + 1, barrel_gap], center=true);
    
    for (a = [-1, 1]) {
      scale([a, 1]) {
        // Shoulder gap, where part of the slider will fit.
        translate([barrel_width/2, barrel_shoulder_height/2])
          square([barrel_shoulder_width*2, barrel_shoulder_height], center=true);
        
        // Cavity for the feed control bars.
        translate([barrel_width/2 - control_bar_width/2 - barrel_shoulder_width, control_bar_height/2 + barrel_gap/2])
          square([control_bar_width, control_bar_height], center=true);
      }
    }
    
    if (feed_cut)
      translate([0, barrel_height/2])
        square([main_bore, barrel_height], center=true);
  }
}

module control_bar_2d(feed_cut=false) {
  difference() {
    translate([barrel_width/2 - control_bar_width/2 - barrel_shoulder_width, control_bar_height/2 + barrel_gap/2])
      square([control_bar_width, control_bar_height], center=true);
    
    circle(d=main_bore);
    
    translate([0, main_bore])
      circle(d=main_bore);
    
    if (feed_cut)
      translate([0, barrel_height/2])
        square([main_bore, barrel_height], center=true);
  }
}

module intrusion_2d() {
  for (a = [-1, 1]) {
    scale([a, 1]) {
      translate([barrel_width/2 - barrel_intrusion/2, 0])
        square([barrel_intrusion, barrel_gap], center=true);
      
      translate([barrel_width/2 - barrel_shoulder_width/2, barrel_shoulder_height/2])
        square([barrel_shoulder_width, barrel_shoulder_height], center=true);
    }
  }
}

barrel_length = 200;
barrel_back_wall = 5;
feed_cut_length = 74;

module barrel() {
  rotate([90, 0, 0]) {
    linear_extrude(barrel_back_wall)
      barrel_2d(false);
    translate([0, 0, barrel_back_wall])
      linear_extrude(feed_cut_length)
        barrel_2d(true);
    translate([0, 0, barrel_back_wall + feed_cut_length])
      linear_extrude(barrel_length - barrel_back_wall - feed_cut_length)
        barrel_2d(false);
  }
}

module control_bars() {
  rotate([90, 0, 0]) {
    for (a = [-1, 1]) {
      scale([a, 1, 1]) {
        linear_extrude(barrel_length - feed_cut_length - barrel_back_wall)
          control_bar_2d(false);
        translate([0, 0, barrel_length - feed_cut_length - barrel_back_wall])
          linear_extrude(feed_cut_length)
            control_bar_2d(true);
        translate([0, 0, barrel_length - barrel_back_wall])
          linear_extrude(barrel_back_wall)
            control_bar_2d(false);
      }
    }
  }
}

barrel();

color("blue") 
  translate([0, 0, 0])
    control_bars();