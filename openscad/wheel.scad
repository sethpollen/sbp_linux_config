eps = 0.001;
layer = 0.2;

height = 80;

// Add 3mm to the radius to account for wear.
diam = 190 + 6;

shell = 0.8;

rim = 12;

tread_depth = 3.5;
tread_width = 4;
tread_count = 25;

axle_hole_diam = 11.4;

spline_cutout_height = 15;
spline_count = 10;
spline_outer_diam = 47;
spline_inner_diam = 35;

module roundoff_2d(r) {
  offset(r)
    offset(-r)
      children();
}

module exterior_2d() {
  roundoff_2d(2, $fn=12) {
    difference() {
      circle(d=diam, $fn=120);
      
      for (a = [0:tread_count-1])
        rotate([0, 0, a * 360 / tread_count])
          translate([diam/2, 0])
            scale([tread_depth, tread_width])
              circle(1, $fn=12);
    }
  }
}

module spline_cutouts_2d() {
  wall = 2.5;
  
  difference() {
    $fn = 32;
    circle(d=spline_outer_diam);
    circle(d=spline_inner_diam);

    for (a = [0:spline_count-1])
      rotate([0, 0, a * 360 / spline_count])
        translate([0, 500])
          square([wall, 1000], center=true);
  }
}

module wheel() {
  difference() {
    linear_extrude(height)
      exterior_2d();
    
    translate([0, 0, -eps])
      linear_extrude(spline_cutout_height)
        spline_cutouts_2d();
  }
}

wheel();