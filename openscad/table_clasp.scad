eps = 0.001;

// Table is 1.5" thick. Add 0.6mm of slack.
table_thickness = 1.5 * 25.4 + 0.6;

gauge = 11;
depth = 10;
flat = 70;

fillet = 20;
chamfer = gauge - 2;

width = 20;

module chop_2d() {
  $fn = 40;
  difference() {
    square(1);
    circle(1);
  }
}

module exterior_2d() {
  difference() {
    union() {
      // Finger.
      translate([-depth, table_thickness])
        square([depth, gauge]);

      // Vertical.
      square([gauge + flat, table_thickness + gauge]);
    }
    
    translate([gauge + fillet, fillet + gauge]) {
      scale(fillet) {
        circle(1, $fn=80);
        translate([-1-eps, 0])
          square(100);
        translate([0, -1-eps])
          square(100);
      }
    }
    
    translate([gauge + flat + eps, gauge - chamfer])
      scale(chamfer)
        translate([-1, 0])
          chop_2d();
  
    translate([eps + gauge - chamfer, table_thickness + gauge + eps])
      scale(chamfer)
        translate([0, -1])
          chop_2d();
  }
}

module exterior() {
  chamf_layers = 5;
  layer = 0.2;

  for (a = [-1, 1]) {
    scale([1, 1, a]) {
      translate([0, 0, -width/2]) {
        for (b = [0:chamf_layers-1]) { 
          translate([0, 0, b*layer]) {
            linear_extrude(layer + eps) {
              intersection() {
                exterior_2d();
                translate((b - chamf_layers)*[layer, layer])
                  exterior_2d();
              }
            }
          }
        }
        
        translate([0, 0, chamf_layers*layer])
          linear_extrude(width/2 - chamf_layers*layer + eps)
            exterior_2d();
      }
    }
  }
}

screw_shaft_diam = 4;
screw_shaft_length = 4.4;
screw_head_diam = 9;
screw_head_height = 4.6;

screw_cav_length = 11;

module octagon(d) {
  intersection() {
    square(d, center=true);
    rotate([0, 0, 45])
      square(d, center=true);
  }
}

module screw_cav() {
  $fn = 30;

  shaft = screw_shaft_diam + 0.4;
  head = screw_head_diam + 1;
  
  translate([0, 0, screw_shaft_length]) {
    translate([0, 0, -10]) {
      linear_extrude(10 + eps) {
        hull() {
          octagon(d=shaft);
          translate([screw_cav_length, 0]) octagon(d=shaft);
        }
        translate([screw_cav_length, 0]) octagon(d=head);
      }
    }

    linear_extrude(screw_head_height) {
      hull() {
        octagon(d=head);
        translate([screw_cav_length, 0]) octagon(d=head);
      }
    }
  }
}

module piece() {
  rotate([90, 0, 0]) {
    difference() {
      rotate([90, 0, 0])
        exterior();
      
      translate([8, 0])
        screw_cav();
      translate([flat - 13, 0])
        screw_cav();
    
      // Pierce the critical section to cause more walls to be printed.
      translate([depth, 0, table_thickness - gauge*1.2])
        rotate([0, -35, 0])
          linear_extrude(100)
            for (a = [0:2], b = [0:20])
              translate([2*a, 6*(b - 10)])
                square(0.3, center=true);
    }
  }
}

piece();