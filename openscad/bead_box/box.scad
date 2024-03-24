wall = 2;

// Exterior dimensions.
width = 70 + 2*wall;
height = 57 + wall;
length = 200 + 2*wall;

div_height = 40 + wall;
chamfer_radius = 1.2;

eps = 0.0001;

module exterior() {
  hull() {
    $fn = 16;
    for (x = (width/2 - chamfer_radius) * [-1, 1], y = [chamfer_radius, length - chamfer_radius]) {
      translate([x, y]) {
        translate([0, 0, chamfer_radius])
          sphere(chamfer_radius);
        translate([0, 0, height])
          linear_extrude(eps)
            circle(chamfer_radius);
      }
    }
  }
}

fillet_radius = 1.3;

module cavities() {
  cavs = 5;
  cav_width = width - 2*wall;
  cav_length = (length - wall * (cavs + 1)) / cavs;
  $fn = 16;

  for (a = [0:cavs-1])
    translate([0, wall + a * (wall + cav_length), wall])
      hull()
        for (
          x = (cav_width/2 - fillet_radius) * [-1, 1],
          y = [fillet_radius, cav_length-fillet_radius],
          z = [fillet_radius, 100]
        )
          translate([x, y, z])
            sphere(fillet_radius);
  
  translate([-cav_width/2, wall, div_height])
    cube([cav_width, length - 2*wall, 100]);
}

module notch() {
  $fn = 50;
  radius = 15;
  
  translate([0, 0, height + radius*0.3])
    rotate([-90, 0, 0])
      translate([0, 0, -1])
        cylinder(h=length+2, r=radius);
}

module box() {
  difference() {
    exterior();
    cavities();
    notch();
  }
}

module daisy_petals() {
  height = 15;
  petals = 10;
  radius = 100;
  petal_radius = 18;
  
  difference() {
    for (t = [0:(petals-1)]) {
      rotate([0, 0, t*(360/petals)]) {
        hull() {
          translate([radius-petal_radius, 0, 0]) circle(petal_radius);
          translate([9, 0, 0]) circle(2.5);
        }
      }
    }
    daisy_center();
  }
}

module daisy_center() {
  circle(30);
}

engrave = 0.6;

module daisy() {
  daisy_petals();
  daisy_center();
}

module daisies() {
  intersection() {
    translate([wall, wall])
      square([height - 2*wall, length - 2*wall]);
    
    union() {
      translate([30, 25])
        scale([0.2, 0.2])
          daisy();
      translate([32, 100])
        scale([0.5, 0.5])
          daisy();
      translate([17, 175])
        scale([0.16, 0.16])
          daisy();
    }
  }
}

module daisy_box() {
  translate([0, 0, -0.02]) {
    difference() {
      box();
    
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([width/2 + eps, 0, 0])
            rotate([0, -90, 0])
              linear_extrude(engrave + eps)
                daisies();
    }
  }
  
  // Adhesion.
  linear_extrude(0.4) {
    for (a = [-1, 1]) {
      scale([a, 1]) {
        translate([width/2-1, 0]) {
          translate([0, 1.5])
            square(6);
          translate([0, length - 7.5])
            square(6);
        }
        translate([width/2-7.5, 0]) {
          translate([0, -3.5])
            square(6);
          translate([0, length - 2.5])
            square(6);
        }
      }
    }
  }
}

daisy_box();