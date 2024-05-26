bot_r = 33/2;
top_r = 30/2;

// The real bases are more like 3.7mm, but printing that requires 0.1mm layers,
// which is slow. Also a 3.7mm base fits a bit too snugly in the castle ladders.
// 3.6mm seems fine.
height = 3.6;

$fn = 200;

inlay_depth = 1;
lip = 0.8;
inlay_slack = 0.3;

module base() {
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
    
    // Inlay well.
    translate([0, 0, height - inlay_depth])
      cylinder(h=inlay_depth+1, r=top_r-lip);
  }
}

module inlay() {
  // Make the inlay 1 layer shorter than the cavity for it, to make sure we don't
  // accidentally thicken the overall part.
  cylinder(h=inlay_depth-0.2, r=top_r-lip-inlay_slack);
}

inlay();