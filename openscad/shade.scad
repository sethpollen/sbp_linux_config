eps = 0.0001;

top_width = 32;
expanded_width = 40.3;
max_height = 30;

module profile() {
  difference() {
    square([expanded_width, max_height + 4]);
    
    translate([expanded_width/2 - 3, max_height-114])
      square(100);
    
    translate([-95, max_height-7])
      square(100);
    
    translate([expanded_width-4, max_height-7])
      square(100);
    
    rotate([0, 0, 20])
      translate([-93, -50])
        square(100);
    
    hull() {
      translate([5, 0]) {
        translate([0, 19])
          square([8, eps]);
        translate([5, 5])
          square([eps, eps]);
      }
    }
    
    translate([8.5, 19])
      square([4.5, 100]);
    
    translate([13, 0])
      rotate([0, 0, -13])
        square(16.5);
  }
}

height = 6;

linear_extrude(0.2)
  offset(-0.3)
    profile();
translate([0, 0, 0.2])
  linear_extrude(height-0.2)
    profile();