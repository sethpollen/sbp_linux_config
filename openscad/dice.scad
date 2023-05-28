include <common.scad>

// A standard size die is 15mm.
//
// Models in this file are centered on the origin.

module square_die_blank() {
  translate([0, 0, -7.5])
    chamfered_box([15, 15, 15]);
}

// Accepts six 2-D children for the six die faces.
module die_imprint() {
  engrave_depth = 1;

  for (case = [
    [0, [0, 0, 1]],  
    [1, [1, 0, 0]],  
    [2, [-1, 0, 0]],  
    [3, [0, 1, 0]],  
    [4, [0, -1, 0]],  
    [5, [0, 2, 1]],  
  ])
    rotate(case[1]*90)
      translate([0, 0, -7.5-eps])
        linear_extrude(engrave_depth)
          children(case[0]);
}

module one_sword() {
  // Blade and hilt.
  polygon([
    [-0.5, -5],
    [-0.25, -5.5],
    [0.25, -5.5],
    [0.5, -5],
    [0.5, 4.5],
    [0, 5.5],
    [-0.5, 4.5],
  ]);
  
  // Crossguard.
  polygon([
    [-1.8, -2],
    [-2, -2.2],
    [-2, -2.8],
    [-1.8, -3],
    [1.8, -3],
    [2, -2.8],
    [2, -2.2],
    [1.8, -2],
  ]);
}

module two_swords() {
  for (a = [-1, 1])
    scale([a, a, 1])
      translate([-2, 0, 0])
        one_sword();
}

module one_star() {
  // Base of an isosceles triangle with height 1 and a 36
  // degree vertex angle.
  base = 0.64983939246581;
  scale_up = 3;
  scale([scale_up, scale_up, 0])
    for (a = [0, 1, 2, 3, 4])
      rotate([0, 0, 360*a/5])
        polygon([
          [-base/2, 0],
          [base/2, 0],
          [0, 1],
        ]);
}

module two_stars() {
  for (a = [-1, 1])
    translate([1.8, 2.5, 0] * a)
      one_star();
}

module empty() {}

// Used for prototyping 2D shapes.
module backdrop() {
  color("purple")
    translate([0, 0, -2])
      linear_extrude(1)
        circle(7);
}

module square_die() {
  difference() {
    square_die_blank();

    die_imprint() {
      one_sword();
      two_swords();
      two_swords();
      empty();
      two_stars();
      one_star();
    }
  }
}

module rounded_die() {
  difference() {
    intersection() {
      square_die_blank();
      sphere(10.4);
    }
    
    die_imprint() {
      two_swords();
      one_sword();
      two_stars();
      two_stars();
      two_stars();
      one_star();
    }
  }
}


// Print 2 dice.
translate([-15, 0, 0])
  rounded_die();
translate([15, 0, 0])
  square_die();
