bot_r = 32.8/2;
top_r = 29.8/2;

// Really the bases seem to be 3.7mm, but let's try this so we can print with 0.2mm layers.
height = 3.6;

$fn = 200;

cylinder(h=0.2, r=bot_r-0.3);
translate([0, 0, 0.2]) cylinder(h=0.4, r=bot_r);
translate([0, 0, 0.6]) cylinder(h=height-0.6, r1=bot_r, r2=top_r);
