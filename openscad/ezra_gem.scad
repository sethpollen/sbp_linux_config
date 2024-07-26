diam = 38;
height = 7;
crown_diam = 20;

module cuts(slope) {
  for (a = [0:7])
    rotate([0, 0, 360*a/8])
      translate([-diam/2, crown_diam/2, height])
        rotate([-slope, 0, 0])
          cube(diam);
}

difference() {
  rotate([0, 0, 360/16])
    cylinder(h=height, d=diam, $fn=8);

  cuts(25);

  translate([0, 0, height-8])
    scale([1, 1, -1])
      cuts(50);
  
  translate([-5.2, -5.5, height-3])
    linear_extrude(20)
      offset(0.5)
        text("E", size=11);
  
  translate([0, 13, -1])
    cylinder(h=20, d=4, $fn=20);
}