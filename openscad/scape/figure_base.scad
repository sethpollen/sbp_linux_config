bot_r = 32.8/2;
top_r = 29.8/2;

// This requires printing with 0.1mm layer height.
height = 3.7;

$fn = 200;
layer = 0.1;

module type1() {
  cylinder(h=0.2, r=bot_r-0.3);
  translate([0, 0, 0.2]) cylinder(h=0.4, r=bot_r);
  translate([0, 0, 0.6]) cylinder(h=height-0.6, r1=bot_r, r2=top_r);
}

module type2() {
  round_r = 0.75;
  difference() {
    rotate_extrude() {
      hull() {
        translate([bot_r-round_r, round_r])
          circle(round_r);
        square([1, height]);
        translate([top_r-1, 0])
          square([1, height]);
      }
    }
    
    // Elephant foot.
    linear_extrude(layer) {
      difference() {
        circle(100);
        circle(bot_r - round_r + 0.1);
      }
    }
  }
}

type2();
