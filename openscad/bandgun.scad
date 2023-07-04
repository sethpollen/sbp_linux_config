$fa = 5;
$fs = 0.5;
eps = 0.001;

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
  r1 = min([radius, x/2, y1/2]);
  r2 = min([radius, x/2, y2/2]);
  
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

// TODO: Remove if unused.
module chamfered_cube(dims, chamfer) {
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
    reify([disp, 0, 0])                 round_rect(55, 24, 24, 12);
    reify([0.9*disp+1, 0, -0.1*height]) round_rect(53, 22, 28, 11);
    reify([0.7*disp, 0, -0.3*height])   round_rect(55, 28, 32, 14);
    reify([0.4*disp, 0, -0.6*height])   round_rect(55, 28, 32, 14);
    reify([0.2*disp, 0, -0.8*height])   round_rect(55, 28, 28, 13);
    reify([1, 0, -height])              round_rect(55, 28, 28, 13);
    reify([0, 0, -height-8])            round_rect(55, 28, 28, 13);
    reify([0, 0, -height-15])           round_rect(55, 28, 28, 14);
    reify([0, 0, -height-16])           round_rect(53, 26, 26, 13);
  }
}

module receiver() {
  height = 8;
  
  difference() {
    union() {
      grip();
      
      // Receiver top.
      translate([-3, -12, 0])
        cube([80, 24, height]);
      
      // Rounded front.
      translate([77, 12, height/2])
        rotate([90, 0, 0])
          cylinder(24, height/2, height/2);
      
      // Rear magazine lug.
      translate([-13, -3, 0])
        cube([10, 6, height]);
    }
    
    // Trigger retention pin cutout.
    translate([75, -8, -1])
      cube([100, 16, 100]);
    
    // Trigger slot.
    translate([5, -3, -20])
      cube([100, 6, 100]);
  }
}

module mag() {
  length = 160;
  
  difference() {
    // TODO: refactor this into an assembly of chamfered_cubes.
    
    // Exterior.
    translate([0, -14, 0])
      chamfered_cube([length, 28, 24], 1);
          
    // Rubber band cutouts along the length.
    for (a = [-1, 1]) {
      scale([1, a, 1]) {
        // Deep channel.
        translate([-1, 6, 3])
          cube([61, 4, 1000]);
        
        // The channel gets shallower near the muzzle.
        //
        // TODO: This would be more easily parameterized as a chain().
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
      
    // Trigger action cutout in back.
    translate([-1, -3, -eps])
      cube([50, 6, 19]);
    translate([-1, -3, -eps])
      cube([10, 6, 100]);
  }
}

module trigger() {
  rotate([0, 0, -90]) {
    intersection() {
      // Nip off the sharp edge on the bottom of the trigger.
      union() {
        translate([0, 8.3, -10.5]) sphere(5);
        translate([0, -14, 0]) cube([10, 50, 26], center=true);
        translate([0, 0, 10]) cube([10, 50, 26], center=true);
      }
      
      difference() {
        // Main trigger volume.
        translate([-3+eps, -25, -13])
          chamfered_cube([6-2*eps, 50, 26], 0.5);
        
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

// TODO: make trigger slightly narrower so it slides freely.

color("red") receiver();
color("yellow") translate([-20, 0, 9]) mag();
color("green") translate([55, 0, -13]) trigger();

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
