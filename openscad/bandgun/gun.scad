$fa = 5;
$fs = 0.5;
eps = 0.001;

// TODO: go over everything. clean up implementation and add comments.

module reify(translation) {
  translate(translation)
    linear_extrude(eps)
      children();
}

module chain(z_steps) {
  if ($children > 0) {
    for (i = [0 : $children-2]) {
      hull() {
         children(i);
         children(i+1);
      }
    }
  }
}

module round_rect(x, y1, y2, radius) {
  hull() {
    for (a = [-1, 1], b = [-1, 1]) {
      y = (a == 1) ? y1 : y2;
      r = min(radius, x/2, y/2);
      translate([
        (x*0.5-r)*a,
        (y*0.5-r)*b,
        0
      ])
        circle(radius);
    }
  }
}

module octahedron(major_radius) {
  // Top and bottom halves.
  for (a = [-1, 1])
    scale([1, 1, a])
      // Extrude a square into a pyramid.
      linear_extrude(major_radius, scale=0)
        rotate([0, 0, 45])
          square(major_radius*sqrt(2), center=true);
}

module chamfered_cube(dims) {
  chamfer = 1;
  assert(dims.x >= chamfer*2);
  assert(dims.y >= chamfer*2);
  assert(dims.z >= chamfer*2);

  hull()
    for (a = [0, 1], b = [0, 1], c = [0, 1])
        translate([
          (dims.x - chamfer*2) * a + chamfer,
          (dims.y - chamfer*2) * b + chamfer,
          (dims.z - chamfer*2) * c + chamfer
        ])
          octahedron(chamfer);
}

// The forward receiver should sit right on the x-y plane when added.
module grip() {
  height = 75;
  angle = 18;
  disp = height*tan(angle);

  chain() {
    reify([disp, 0, 2])                    round_rect(59, 24, 23, 11);
    reify([disp-2, 0, 0])                  round_rect(59, 24, 23, 11);
    reify([0.96*disp+0.5, 0, -0.04*height])round_rect(54, 22, 24, 11);
    reify([0.85*disp+1, 0, -0.15*height])  round_rect(53, 22, 26, 11);
    reify([0.65*disp, 0, -0.35*height])    round_rect(55, 28, 32, 14);
    reify([0.4*disp, 0, -0.6*height])      round_rect(55, 28, 32, 14);
    reify([0.2*disp, 0, -0.8*height])      round_rect(55, 28, 28, 13);
    reify([1, 0, -height])                 round_rect(55, 28, 28, 13);
    reify([0, 0, -height-8])               round_rect(55, 28, 28, 13);
    reify([0, 0, -height-15])              round_rect(55, 28, 28, 14);
    reify([0, 0, -height-16])              round_rect(53, 26, 26, 13);
  }
}

travel = 16;

module rail_octahedon() {
  octahedron(1.8);
}

// TODO: chamfer all edges which will be against the build plate, to make it less
// vital to sand off the brim.

module receiver() {
  difference() {
    union() {
      difference() {
        // Main volume.
        union() {
          grip();
          
          // Receiver top.
          translate([-11, -12, 0])
            chamfered_cube([89, 24, 6]);
          
          // Extra material around rear lug slot.
          translate([-8.5, -7, -1])
            chamfered_cube([10, 14, 7-eps]);
        }
        
        // Rear lug slot.
        translate([-10, 4, 3])
          rotate([90, 0, 0])
            cylinder(8.2, 4, 4);
        
        // Chamfer the receiving lips of the rear lug slot.
        for (y = [-4.2, 4.2])
          hull()
            for (z = [-1, 20])
              translate([-11, y, z])
                octahedron(1);
                
        // Remove trigger slot.
        translate([20-travel, -3, -25])
          cube([100, 6, 100]);
      }
      
      // Add rails which intrude into the trigger slot.
      for (y = [-3.2, 3.2])
        translate([0, y, 3])
          hull()
            for (x = [-1, 100])
              translate([x, 0, 0])
                rail_octahedon();    
    }
    
    // Remove material from the front which will be replaced by a glued-in
    // retainer for the action.
    translate([70, -8, -50])
      cube([100, 16, 100]);
  }
}

// Piece which is glued to the front of the receiver to keep the trigger
// from falling out.
module retainer() {
  difference() {
    union() {
      // Back.
      translate([0, -8, 0])
        cube([8, 16, 6]);
      
      // Rounded front.
      translate([8, 8, 4])
        rotate([90, 0, 0])
          cylinder(16, 2, 2);
      
      // Stud on top which engages a hole in the bottom of the mag, to keep
      // the mag from yawing.
      chain() {
        reify([4, 0, 6-eps]) circle(3);
        reify([4, 0, 6.5]) circle(2.2);
        reify([4, 0, 7]) circle(3);
        reify([4, 0, 9]) circle(1);
      }
    }
    
    // Bottom chamfer.
    hull()
      for (y = [-100, 100])
        translate([8, y, 0])
          octahedron(1);
      
    // Side chamfers.
    for (y = [-8, 8])
      hull()
        for (z = [-100, 100])
          translate([10, y, z])
            octahedron(2);
  }
}

// TODO: we don't need such a big gap between the receiver and mag. Bring it down to 0.1mm.
// Hopefully that will reduce rattling.

module mag() {
  length = 160;
  
  difference() {
    // TODO: refactor this into an assembly of chamfered_cubes.
    
    // Exterior.
    translate([0, -14, 0])
      chamfered_cube([length, 28, 24]);
          
    // Rubber band cutouts along the length.
    for (a = [-1, 1]) {
      scale([1, a, 1]) {
        // Deep channel.
        translate([-1, 6, 3])
          cube([61, 4, 1000]);
        
        // The channel gets shallower near the muzzle.
        translate([60, 6, 3])
          rotate([0, -5, 0])
            cube([1000, 4, 1000]);
        
        // Shorten the walls along the entire length.
        translate([-1, 9, 20])
          cube([1000, 6, 1000]);
      }
    }
    
    // Chamfer the outer edges.
    for (y = [-14, 14], z = [0, 20])
      translate([0, y, z])
        hull()
          for (x = [-1000, 1000])
            translate([x, 0, 0])
              octahedron(1);
          
    // Chamfer the inner edges.
    for (y = [-10, 10])
      translate([0, y, 20])
        hull()
          for (x = [-1000, 1000])
            translate([x, 0, 0])
              octahedron(1);
          
    // Chamfer the top edges.
    for (y = [-6, 6])
      translate([0, y, 24])
        hull()
          for (x = [-1000, 1000])
            translate([x, 0, 0])
              octahedron(1);
          
    // Chamfer the front edges of the outer fences.
    for (x = [0, length], a = [-1, 1])
      scale([1, a, 1])
        hull()
          for (y = [8, 100])
            translate([x, y, 20])
              octahedron(1);
      
    // Trigger action cutout in back. Use a chamfered cube to make the
    // bridge above easier to print.
    translate([-1, -3, -1-eps])
      chamfered_cube([75, 6, 20]);
          
    // Chamfer inside for a "flared magwell" effect.
    translate([-106, -4, -9])
      chamfered_cube([200, 8, 10]);
          
    // Full height cutout at the very back.
    translate([-1, -3, -eps])
      cube([10, 6, 100]);
          
    // Cutout for stud on top of retainer.
    translate([94, 0, 0]) {
      chain() {
        reify([0, 0, -eps]) circle(3.5);
        reify([0, 0, 0.8]) circle(3.3);
        reify([0, 0, 2.8]) circle(1.3);
        reify([0, 0, 3.5]) circle(1.3);
      }
    }
  }
  
  // Front attachment lug.
  translate([101.6, 0, -4]) {
    translate([-1, -4, -1])
      chamfered_cube([3, 8, 8]);
    translate([0, 4, 0]) {
      rotate([90, 0, 0]) {
        chain() {
          reify([0, 0, 0]) circle(1);
          reify([0, 0, 1]) circle(2);
          reify([0, 0, 7]) circle(2);
          reify([0, 0, 8]) circle(1);
        }
      }
    }
  }
  
  // Rear attachment lug.
  translate([10, 4, -3.2]) {
    rotate([90, 0, 0]) {
      chain() {
        reify([0, 0, 0]) circle(3);
        reify([0, 0, 1]) circle(4);
        reify([0, 0, 7]) circle(4);
        reify([0, 0, 8]) circle(3);
      }
    }
  }
  translate([6, -4, -4.2])
    chamfered_cube([6, 8, 9]);
}

module trigger() {
  rotate([0, 0, -90]) {
    intersection() {
      // Nip off the sharp edge on the bottom of the trigger.
      union() {
        translate([0, 7.6, -10])
          sphere(5);
        rotate([-10, 0, 0])
          translate([0, -14, 0])
            cube([10, 50, 100], center=true);
      }
      
      difference() {
        // Main trigger volume.
        translate([-3+eps, -35, -12])
          cube([6-2*eps, 60, 24], 0.5);
        
        // Chamfer bottom edges (which will have a brim when printed).
        for (x = [-3, 3])
          translate([x, 0, -12])
            hull()
              for (y = [-1000, 1000])
                translate([0, y, 0])
                  octahedron(1);
        
        // Saddle-shaped cutout where the finger touches it.
        translate([-3, 30, 0]) {
          rotate([0, 0, 0]) {
            rotate([0, 90, 0]) {
              rotate_extrude(angle=180) {
                translate([-24, 0, 0]) {
                  difference() {
                    square([24, 6]);
                    translate([0, 3, 0]) circle(3.3);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module action() {
  difference() {
    intersection() {
      union() {
        trigger();
              
        difference() {
          union() {
            // Sliding bar on top of trigger.
            translate([-35, -3, 12-eps])
              cube([50, 6, 6]);

            // Extension up into mag.
            translate([-35, -3, 12])
              cube([30, 6, 23]);
          }
          
          // Rails.
          for (y = [-3, 3])
            translate([0, y, 15])
              hull()
                for (x = [-1000, 1000])
                  translate([x, 0, 0])
                    rail_octahedon();
        }
                    
        // Extension backwards towards the steps.
        translate([-70, -3, 19])
          cube([60, 6, 16]);
      }
      
      // Shave off 0.2mm on both sides so it slides freely.
      cube([1000, 5.4, 1000], center=true);
    
      // Taper the top of the rearward extension, to make it easier to snap the mags
      // down on top.
      translate([-100, 0, -40]) {
        rotate([90, 0, 0]) {
          rotate([0, 90, 0]) {
            linear_extrude(200) {
              polygon([
                [10, 0],
                [0, 85],
                [-10, 0],
              ]);
            }
          }
        }
      }
    }
    
    // Knock off the most prominent corner too, for the same reason.
    translate([-5, 0, 18])
      rotate([0, -20, 0])
        translate([50, 0, 50])
          cube([100, 10, 100], center=true);
    
    // Slot for the trigger spring band.
    translate([-35, 0, 18.7]) {
      rotate([90, 0, 0]) {
        chain() {
          reify([0, 0, -3]) for (a = [0, 1]) translate([a, 0, 0]) circle(1.5);
          reify([0, 0, -1]) for (a = [0, 1]) translate([a, 0, 0])  circle(0.6);
          reify([0, 0, 1]) for (a = [0, 1]) translate([a, 0, 0])  circle(0.6);
          reify([0, 0, 3]) for (a = [0, 1]) translate([a, 0, 0])  circle(1.5);
        }
      }
    }
    
    // Retention band guides.
    for (y = [-3, 3])
      translate([0, y, 18.7])
        hull()
          for (x = [-35, 1000])
            translate([x, 0, 0])
              octahedron(1);
  }
}

module gun() {
  color("red") receiver();
  color("gray") translate([70+eps, 0, 0]) retainer();
  color("yellow") translate([-20, 0, 6.2]) mag();
  color("green") translate([55, 0, -12]) action();
}

// Cross section.
projection(cut=true) rotate([90, 0, 0])
gun();

// https://www.thingiverse.com/thing:3985409
//   163mm stretched band length
//   trigger assembly 6mm thick
//   side panels 3mm thick
//   So total thickness is about 12mm.
//
//   Say the bands need 4mm of clearance.
//   Then add another 3mm wall. We'll have a total mag width of 
//   26mm. Which is about the width of the S&W M&P 9mm slide.
//
//   Action travel is 16mm.
