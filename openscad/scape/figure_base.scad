bot_r = 32.8/2;
top_r = 29.8/2;
height = 3.7;

$fn = 200;

cylinder(h=0.1, r=bot_r-0.2);
translate([0, 0, 0.1]) cylinder(h=0.1, r=bot_r-0.13);
translate([0, 0, 0.2]) cylinder(h=0.1, r=bot_r-0.06);
translate([0, 0, 0.3]) cylinder(h=0.3, r=bot_r);
translate([0, 0, 0.6]) cylinder(h=height-0.6, r1=bot_r, r2=top_r);
