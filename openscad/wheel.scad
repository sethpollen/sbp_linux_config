eps = 0.001;
layer = 0.2;

height = 80;

// Add 3mm to the radius to account for wear.
diam = 190 + 6;

shell = 0.8;

rim_thickness = 13;

tread_depth = 3.5;
tread_width = 4;
tread_count = 25;

axle_hole_diam = 11.4;

spline_cutout_height = 15;
spline_count = 10;
spline_outer_diam = 47;
spline_inner_diam = 35;

edge_bevel = 12;

// A large enough core cylinder to contain the splines and axle hole,
// but not so large that it approaches the rim cavity.
core_diam = diam/2;

module roundoff_2d(r) {
  offset(r)
    offset(-r)
      children();
}

module shell_2d() {
  difference() {
    children();
    offset(-shell)
      children();
  }
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

module rim_2d() {
  shell_2d()
    exterior_2d();
    
  difference() {
    circle(d=diam-2*rim_thickness);
    circle(d=core_diam);
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

module rim() {
  bevel_scale = 0.96;
  
  // Bottom plate.
  linear_extrude(shell) {
    difference() {
      scale(bevel_scale * [1, 1])
        exterior_2d();
      circle(d=core_diam);
    }
  }
  
  // Top bevel.
  translate([0, 0, height - edge_bevel - eps])
    linear_extrude(edge_bevel, scale=bevel_scale)
      rim_2d();
  
  // Bottom bevel.
  translate([0, 0, edge_bevel + eps])
    scale([1, 1, -1])
      linear_extrude(edge_bevel, scale=bevel_scale)
        rim_2d();
  
  // Middle.
  translate([0, 0, edge_bevel])
    linear_extrude(height - 2*edge_bevel) 
      rim_2d();
}

module wheel() {
  difference() {
    cylinder(h=height, d=core_diam+5);
    
    translate([0, 0, -eps]) {
      linear_extrude(spline_cutout_height)
        spline_cutouts_2d();
      
      cylinder(h=height+1, d=axle_hole_diam, $fn=50);
    }
  }
  
  color("orange")
    rim();
}

// TODO: piercings

wheel();