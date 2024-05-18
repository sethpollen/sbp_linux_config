bot_r = 32.8/2;
top_r = 29.8/2;

// The real bases are more like 3.7mm, but printing that requires 0.1mm layers,
// which is slow. Also a 3.7mm base fits a bit too snugly in the castle ladders.
// 3.6mm seems fine.
height = 3.6;

$fn = 200;

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
    linear_extrude(0.2) {
      difference() {
        circle(100);
        circle(bot_r - round_r + 0.05);
      }
    }
  }
}

type2();
