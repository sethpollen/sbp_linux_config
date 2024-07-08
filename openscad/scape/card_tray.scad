// Cavity dimensions.
major_width = 133;
major_height = 85;
minor_width = 89;
minor_height = 41;

eps = 0.001;
wall = 1;  // TODO: thicker

module cavity_2d(boxy=false) {
  for (a = [-1, 1]) {
    scale([a, 1]) {
      polygon([
        [-eps, 0],
        [minor_width/4, 0],
        [minor_width/2, boxy ? 0 : minor_width*tan(30)/4],
        [minor_width/2, boxy ? 0 : minor_height],
        [major_width/2, boxy ? 0 : minor_height + (major_width-minor_width)*tan(30)/2],
        [major_width/2, major_height],
        [-eps, major_height],
      ]);
    }
  }
}

module inner_profile_2d() {
  translate([0, wall]) {
    difference() {
      offset(delta=wall)
        cavity_2d(boxy=true);
      cavity_2d(boxy=false);
      
      // Cut off the ceiling.
      translate([-500, major_height - eps])
        square(1000);
    }
  }
}

module end_profile_2d() {
  hull()
    inner_profile_2d();
}

module tray() {
  cavity_length = 25;
  end_wall = 1; // TODO: thicker
  
  rotate([90, 0, 0]) {
    linear_extrude(end_wall) end_profile_2d();
    translate([0, 0, end_wall]) linear_extrude(cavity_length) inner_profile_2d();
    translate([0, 0, end_wall+cavity_length]) linear_extrude(end_wall) end_profile_2d();
  }
}

module main() {
  intersection() {
    tray();
    translate([-500, -500, 0.2])
      cube(1000);
  }
  linear_extrude(0.2)
    offset(-0.3)
      projection(cut=true)
        translate([0, 0, -0.1])
          tray();
}

main();