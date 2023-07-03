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
  assert(x >= radius*2);
  assert(y1 >= radius*2);
  assert(y2 >= radius*2);
  
  hull()
    for (a = [-1, 1], b = [-1, 1])
      translate([
        (x*0.5-radius)*a,
        ((a == 1 ? y1 : y2)*0.5-radius)*b,
        0
      ])
        circle(radius);
}

// The forward receiver should sit right on the x-y plane when added.
module grip() {
  height = 75;
  angle = 18;
  disp = height*tan(angle);

  chain() {
    reify([disp-4, 0, 8])               round_rect(63, 23, 23, 6);
    reify([disp-4, 0, 6])               round_rect(63, 23, 23, 6);
    reify([disp-1, 0, 3])               round_rect(57, 23, 23, 6);
    reify([disp, 0, 0])                 round_rect(55, 28, 28, 13);
    reify([0.9*disp+1, 0, -0.1*height]) round_rect(53, 24, 28, 12);
    reify([0.7*disp, 0, -0.3*height])   round_rect(55, 28, 32, 14);
    reify([0.4*disp, 0, -0.6*height])   round_rect(55, 28, 32, 14);
    reify([0.2*disp, 0, -0.8*height])   round_rect(55, 28, 28, 13);
    reify([1, 0, -height])              round_rect(55, 28, 28, 13);
    reify([0, 0, -height-8])            round_rect(55, 28, 28, 13);
    reify([0, 0, -height-15])           round_rect(55, 28, 28, 14);
    reify([0, 0, -height-16])           round_rect(53, 26, 26, 13);
  }
}

module guard_profile() {
  round_rect(3, 6, 6, 1);
}

// Trigger guard.
module guard() {
  major_length = 30;
  minor_length = 20;
  turn_radius = 5;
  
  chain() {
    reify([0, 0, 0]) guard_profile();
    reify([0, 0, major_length]) guard_profile();
  }
  
  translate([-turn_radius, 0, major_length])
    rotate([90, 0, 0])
      rotate_extrude(angle=70)
        translate([turn_radius, 0, 0])
          guard_profile();
  
  translate([-turn_radius, 0, major_length]) {
    rotate([90, 0, 0]) {
      rotate([-90, 0, 70]) {
        translate([turn_radius, 0, 0]) {
          chain() {
            reify([0, 0, 0]) guard_profile();
            reify([0, 0, minor_length]) guard_profile();
          }
        }
      }
    }
  }
}

module receiver() {
  grip();
}

receiver();

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

module mag() {
  difference() {
    chain() {
      reify([0, 0, 0])   round_rect(30, 12, 12, 2);
      reify([0, 0, 100]) round_rect(30, 12, 12, 2);
      reify([9, 0, 100]) round_rect(12, 12, 12, 2);
      reify([9, 0, 160]) round_rect(12, 12, 12, 2);
      reify([9, 0, 161]) round_rect(11, 10, 10, 2);
    }
    
    // Nose notch.
    translate([10.5, 0, 161]) {
      rotate([90, 0, 0]) {
        for (a = [-1, 1]) {
          scale([1, 1, a]) {
            chain() {
              reify([0, 0, -eps]) for (b = [-1, 1]) translate([b, 0, 0]) circle(1.5);
              reify([0, 0, 4]) for (b = [-1, 1]) translate([b, 0, 0]) circle(1.5);
              reify([0, 0, 5]) for (b = [-1, 1]) translate([b, 0, 0]) circle(2);
              reify([0, 0, 6]) for (b = [-1, 1]) translate([b, 0, 0]) circle(3);
            }
          }
        }
      }
    }
  }
}
