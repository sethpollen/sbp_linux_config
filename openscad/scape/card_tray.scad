eps = 0.001;

// Cavity dimensions.
major_width = 133;
major_height = 82;
minor_width = 89;
minor_height = 40;

cavity_length = 30;

wall = 1; // TODO: thicker
roundoff = min(wall*0.45, 1.8);

module cavity_2d(boxy=false) {
  flat = 1;
  for (a = [-1, 1]) {
    scale([a, 1]) {
      polygon([
        [-eps, boxy ? 0 : minor_width*tan(30)/4],
        [minor_width/4, 0],
        [minor_width/4 + flat, 0],
        [minor_width/2 + flat, boxy ? 0 : minor_width*tan(30)/4],
        [minor_width/2 + flat, boxy ? 0 : minor_height],
        [major_width/2 + flat, boxy ? 0 : minor_height + (major_width-minor_width)*tan(30)/2],
        [major_width/2 + flat, major_height],
        [-eps, major_height],
      ]);
      
      // Flare the bottom to make it easier to drop the cards in.
      translate([-minor_width/2, minor_height-13])
        rotate([0, 0, 17])
          square([20, 35]);
    }
  }
}

module inner_profile_2d(boxy=false) {
  offset(roundoff, $fn=30) {
    offset(-roundoff) {
      translate([0, wall]) {
        difference() {
          offset(delta=wall)
            cavity_2d(boxy=boxy);
          cavity_2d(boxy=false);
          
          // Cut off the ceiling.
          translate([-500, major_height - eps])
            square(1000);
        }
      }
    }
  }
}

module end_profile_2d() {
  hull()
    inner_profile_2d(boxy=true);
}

module tray() {
  end_wall = 1; // TODO: thicker
  
  difference() {
    rotate([90, 0, 0]) {
      linear_extrude(end_wall) end_profile_2d();
      translate([0, 0, end_wall]) linear_extrude(cavity_length) inner_profile_2d(boxy=true);
      translate([0, 0, end_wall+cavity_length]) linear_extrude(end_wall) end_profile_2d();
    }
    
    for (y = [0, -end_wall*2 - cavity_length])
      translate([0, y])
        rotate([45, 0, 0])
          cube([1000, 0.5, 0.5], center=true);
  }
}

module main() {
  difference() {
    tray();
    translate([-500, -5, 0])
      cube(1000);
  }
}

main();