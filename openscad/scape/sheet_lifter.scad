// Use 0.3mm layers.

hole_spacing = 216;
$fn = 40;
height = 1.5;

module exterior_2d() {
  diam = 30;
  
  hull() {
    for (a = [-1, 1]) {
      translate([0, a*hole_spacing/2])
        circle(d=diam);
      
      translate([hole_spacing/3, a*hole_spacing/4])
        circle(d=diam);
    }
  }
}

module holes_2d() {
  for (a = [-1, 0, 1])
    translate([0, a*hole_spacing/2])
      hull()
        for (b = [-1, 0])
          translate([b*6-2, 0])
            circle(d=6);
}

module skeleton_2d() {
  difference() {
    exterior_2d();
    offset(-28)
      exterior_2d();
  }
}

module profile_2d() {
  difference() {
    skeleton_2d();
    holes_2d();
  }
}

module main() {
  rotate([0, 0, 45]) {
    linear_extrude(0.3)
      offset(-0.3)
        profile_2d();
    translate([0, 0, 0.3])
      linear_extrude(height-0.3)
        profile_2d();
  }
}

main();