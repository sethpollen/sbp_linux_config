length = 18;
d = 5;
$fn = 8;

rotate([90, 0, 0])
  rotate([0, 0, 360/16])
    cylinder(h=length, d=d);