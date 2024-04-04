eps = 0.001;

// Fast print setting.
layer = 0.3;

height = 80;
diam = 190;

shell = 0.8;

rim = 12;

tread_depth = 3.5;
tread_width = 4;
tread_count = 25;

spoke_width = 9;
spoke_count = 8;

axle_hole_diam = 11.4;

spline_cutout_height = 15;
spline_count = 10;
spline_outer_diam = 47;
spline_inner_diam = 35;

edge_bevel = 12;

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

module spoke_cutouts_2d() {
  roundoff_2d(10, $fn=16) {
    difference() {
      circle((diam/2)-rim, $fn=32);
      
      for (a = [0:spoke_count-1])
        rotate([0, 0, a * 360 / spoke_count])
          translate([0, 500])
            square([spoke_width, 1000], center=true);
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

module profile_2d() {
  difference() {
    exterior_2d();
    
    spoke_cutouts_2d();
    
    circle(d=axle_hole_diam, $fn=50);
  }
}

module web_2d() {
  intersection() {
    profile_2d();

    rotate([0, 0, 180/spoke_count])
      for (a = [0:spoke_count-1])
        rotate([0, 0, a * 360 / spoke_count])
          translate([0, diam/4])
            square([shell, diam/2], center=true);
  }
}

module wheel_shell() {
  // Bottom shell.
  linear_extrude(shell) {
    difference() {
      profile_2d();
      spline_cutouts_2d();
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

      // Fins to help splines adhere.
      fin_count = spline_count;
      for (a = [1:fin_count]) {
        rotate([0, 0, a * 360 / fin_count]) {
          translate([spline_inner_diam/2 - 4, 0])
            square([3.8, shell]);
          translate([spline_outer_diam/2 + 0.2, 0])
            square([1.8, shell]);
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
      circle(d=axle_hole_diam+4, $fn=50);
      circle(d=axle_hole_diam+0.5, $fn=50);
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

// If sense=true, this gives the wall to be printed. If sense=false,
// this gives a negative to be subtracted from the wheel before adding
// the wall.
module cutout_3d(sense=true) {
  intersection() {
    if (sense)
      linear_extrude(height)
        profile_2d();
    
    union() {
      // Torus to remove mass from the inside of the spokes.
      torus_radius = diam*0.16;
      translate([0, 0, height/2]) {
        scale([1, 1, 0.7 * height / (torus_radius*2)]) {
          rotate_extrude($fn=40) {
            translate([diam*0.28, 0]) {
              if (sense) {
                difference() {
                  circle(torus_radius, $fn=32);
                  circle(torus_radius-shell, $fn=32);
                }
              } else {
                circle(torus_radius-shell, $fn=32);
              }
            }
          }
        }
      }
      
      // Bevel the edges of the wheel.
      translate([0, 0, height/2]) {
        for (a = [-1, 1]) {
          scale([1, 1, a]) {
            translate([0, 0, height/2 - edge_bevel]) {
              difference() {
                $fn = 120;
                
                inset = edge_bevel * 0.7;
                
                if (sense)
                  cylinder(h=edge_bevel+eps, d1=diam+2*shell, d2=diam-inset+2*shell);
                else
                  cylinder(h=edge_bevel+eps, d=diam+1);

                translate([0, 0, -eps])
                  cylinder(h=edge_bevel+3*eps, d1=diam, d2=diam-inset);
              }
            }
          }
        }
      }
    }
  }
}

// Wheel with weight saving cutouts in the spokes.
module wheel2_shell() {
  difference() {
    wheel_shell();
    cutout_3d(false);
  }
  cutout_3d(true);
}

// For measuring the volume of casting epoxy needed to fill the shell.
module wheel2_full() {
  difference() {
    linear_extrude(height)
      profile_2d();
    cutout_3d(false);
  }
}

wheel2_shell();