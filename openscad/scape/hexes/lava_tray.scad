$fn = 30;

module tile_profile_2d() {
  projection()
    scale(25.4 * [1, 1, 1])
      rotate([-90, 0, 0])
        import("originals/glacier_1hex.stl", 5);
}

module exterior_2d() {
  circle(r = 30, $fn = 6);
}

module shell_2d() {
  offset(0.4) {
    difference() {
      exterior_2d();
      offset(1.5)
        tile_profile_2d();
    }
  }
}

difference() {
  union() {
    linear_extrude(1.2) exterior_2d();
    linear_extrude(15) shell_2d();
  }
  
  translate([0, 0, -1]) {
    translate([0, 50, 0])
      cube([24, 100, 100], center=true);
    cylinder(h=100, d=24);
  }
}