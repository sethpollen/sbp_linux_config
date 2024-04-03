eps = 0.0001;

height = 80;
diam = 190;

outer_wall = 22;

module exterior_2d() {
  tread_depth = 5;
  roundoff = 2;
  
  offset(roundoff, $fn=16) {
    offset(-roundoff) {
      difference() {
        circle(d=diam, $fn=120);
        
        for (a = [0:15:359])
          rotate([0, 0, a])
            translate([diam/2, 0])
              circle(tread_depth, $fn=16);
      }
    }
  }
}

module profile_2d() {
  difference() {
    exterior_2d();
    circle(d=diam-2*outer_wall, $fn=120);
  }
}

linear_extrude(height)
  profile_2d();