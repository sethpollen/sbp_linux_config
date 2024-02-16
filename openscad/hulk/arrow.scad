length = 16;
width = 12;
height = 5;

eps = 0.0001;

module head_2d() {
  hull() {
    square([eps, 0.8], center=true);
    translate([width/2, 0])
      square([1.1, width], center=true);
  }
}

module tail_2d() {
  translate([width/2 - 1, -width/4])
    square([length - width/2 + 1, width/2]);
}

module extrude() {
  hull() {
    translate([0, 0, height/2])
      linear_extrude(height/2)
        offset(-0.4)
          children();
    
    // Slightly stronger chamfer on bottom.
    linear_extrude(height/2)
      offset(-0.7)
        children();

    translate([0, 0, 0.4])
      linear_extrude(height - 0.8)
        children();
  }
}

module arrow() {
  extrude() head_2d();
  extrude() tail_2d();
}

arrow();