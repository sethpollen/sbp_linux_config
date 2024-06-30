eps = 0.001;

// Height of a normal terrain piece, when stacked.
block_height = 9.6;

// Underbrush is 9*9.6 = 86mm.
// Trees:
//   14*9.6 = 134
//   15*9.6 = 144
//   16*9.6 = 154

tree_trunk_diam = 3.4;

// Minor diameter of the base.
base_minor_diam = 38;
base_major_diam = 43.88;

module base_2d() {
  roundoff = 2;
  offset(roundoff, $fn = 20)
    offset(-roundoff)
      hull()
        for (a = [0:5])
          rotate([0, 0, a*60])
            translate([base_major_diam/2, 0])
              square(eps, center=true);
}

module tree_trunk_2d() {
  ;
  difference() {
    circle(d=tree_trunk_diam+slack+2*wall);
    circle(d=tree_trunk_diam+slack);
  }
}

module main() {
  $fn = 30;
  tree_trunk_wall = 1.5;
  tree_trunk_slack = 0.4;
  tree_trunk_height = 20;

  difference() {
    union() {
      intersection() {
        linear_extrude(10)
          base_2d();
        translate([0, 0, -25])
          sphere(d=base_major_diam*1.6, $fn=90);
      }
      
      // Tree trunk.
      linear_extrude(tree_trunk_height)
        circle(d=tree_trunk_diam+tree_trunk_slack+2*tree_trunk_wall);
      translate([0, 0, tree_trunk_height])
        scale([1, 1, 0.5])
          sphere(d=tree_trunk_diam+tree_trunk_slack+2*tree_trunk_wall);
      
      // Hills around foliage bases.
      for (a = [0:5])
        rotate([0, 0, 60*a])
          translate([10, 0, 1.2])
            rotate([0, 10, 0])
              translate([0, 0, 6])
                sphere(d=6);
    }
    
    // Tree trunk cavity.
    translate([0, 0, 1])
      linear_extrude(100)
        circle(d=tree_trunk_diam+tree_trunk_slack);
  
    // Foliage cavities.
    for (a = [0:5])
      rotate([0, 0, 60*a])
        translate([10, 0, 1.2])
          rotate([0, 10, 0])
            cylinder(h=20, d=2.8);
  }
}

main();