$fn = 20;

difference() {
  cube([30, 2, 1]);
  
  // Chamfered bottom.
  rotate([45, 0, 0])
    cube([100, 0.4, 0.4], center=true);
  translate([0, 2, 0])
    rotate([45, 0, 0])
      cube([100, 0.4, 0.4], center=true);
  
  // Pointy tip.
  translate([0, 1.2, -0.5])
    rotate([0, 0, 10])
      cube([20, 20, 2]);
  translate([0, 0.8, -0.5])
    rotate([0, 0, -10])
      translate([0, -20, 0])
        cube([20, 20, 2]);
  
  // Hole.
  translate([28.7, 1, -1])
    cylinder(4, d=1.2);
  translate([28.7, 1, -0.0001])
    linear_extrude(0.3, scale=0.6667)
      circle(r=0.8);
}

