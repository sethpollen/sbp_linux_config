use <base.scad>
use <body.scad>
use <head.scad>

repeaty(3, 15)
  basic_body(outstretched_arms=[false,true], bony=true);

translate([45, -50, 0])
  repeaty(3, 50)
    base();
    
translate([-45, -50, 0])
  repeaty(3, 50)
    skeleton_head();