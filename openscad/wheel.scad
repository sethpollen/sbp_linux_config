eps = 0.0001;

// Fast print setting.
layer = 0.3;

height = 80;
diam = 190;

shell = 0.8;

rim = 14;

tread_depth = 4;
tread_count = 25;

spoke_width = 9;
spoke_count = 8;

axle_hole_diam = 12;

spline_cutout_height = 15;

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
  roundoff_2d(2, $fn=16) {
    difference() {
      circle(d=diam, $fn=120);
      
      for (a = [0:tread_count-1])
        rotate([0, 0, a * 360 / tread_count])
          translate([diam/2, 0])
            circle(tread_depth, $fn=16);
    }
  }
}

module spoke_cutouts_2d() {
  roundoff_2d(10, $fn=16) {
    difference() {
      circle((diam/2)-rim, $fn=60);
      
      for (a = [0:spoke_count-1])
        rotate([0, 0, a * 360 / spoke_count])
          translate([0, 500])
            square([spoke_width, 1000], center=true);
    }
  }
}

module spline_cutouts_2d() {
  wall = 2.5;
  count = 10;
  
  outer_diam = 47;
  inner_diam = 35;
  
  difference() {
    circle(d=outer_diam);
    circle(d=inner_diam);

    for (a = [0:count-1])
      rotate([0, 0, a * 360 / count])
        translate([0, 500])
          square([wall, 1000], center=true);
  }
}

module profile_2d() {
  difference() {
    exterior_2d();
    
    spoke_cutouts_2d();
    
    circle(d=axle_hole_diam, $fn=60);
  }
}

module web_2d() {
  intersection() {
    profile_2d();

    rotate([0, 0, 180/spoke_count]) {
      for (a = [0:spoke_count-1])
        rotate([0, 0, a * 360 / spoke_count])
          translate([0, 500])
            square([shell, 1000], center=true);
      
      difference() {
        $fn = spoke_count;
        circle(d=diam*0.6);
        circle(d=diam*0.6-2*shell);    
      }
    }
  }
}

module wheel() {
  // Bottom layer (elephant foot).
  linear_extrude(layer) {
    offset(-0.3) {
      difference() {
        profile_2d();
        spline_cutouts_2d();
      }
    }
  }
  
  // Rest of bottom shell.
  translate([0, 0, layer]) {
    linear_extrude(shell - layer) {
      difference() {
        profile_2d();
        spline_cutouts_2d();
      }
    }
  }
  
  // Length of wheel with spline cutouts.
  translate([0, 0, shell]) {
    linear_extrude(spline_cutout_height - shell) {
      shell_2d() {
        difference() {
          profile_2d();
          spline_cutouts_2d();
        }
      }
    }
  }
  
  // Rest of wheel.
  translate([0, 0, spline_cutout_height])
    linear_extrude(height - spline_cutout_height)
      shell_2d()
        profile_2d();
  
  // Ceiling of spline cutouts. Make this extra thick, since it's load bearing.
  translate([0, 0, spline_cutout_height])
    linear_extrude(shell * 2)
      offset(shell)
        spline_cutouts_2d();
  
  // Reinforce the axle bearing to make sure it prints nicely.
  linear_extrude(height) {
    difference() {
      circle(d=axle_hole_diam+4, $fn=60);
      circle(d=axle_hole_diam+0.5, $fn=60);
    }
  }
  
  web_height = 1.8;
  web_count = 4;
  
  web_spacing = (height * 0.88) / web_count;
  for (a = [1:web_count])
    translate([0, 0, height * 0.05 + a * web_spacing - web_height])
      linear_extrude(web_height)
        web_2d();
}

// Print enough to test the drive splines and axle fit.
module preview() {
  intersection() {
    wheel();
    scale([2, 2, 1])
      sphere(20);
    cylinder(h=100, r=27);
  }
}

wheel();