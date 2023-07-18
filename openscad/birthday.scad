use <morph.scad>

$fa = 20; // TODO: 5 or 8
$fs = 0.2;
$zstep = 0.2;
eps = 0.001;

function circ(x) = 1-sqrt(1-x*x);

module enflesh(height, radius) {
  morph([
    [0,      [0]],
    [height, [1]],
  ])
    offset(r=-radius*circ($m[0]))
      children();
}

module mytext(s) {
  text(s, size=13, font="Anaktoria:style=Bold");
}

layer_thickness = 1.5;

daisy1_center = [20, 40, 0];
daisy1_scale = 0.19;

daisy2_center = [-20, 50, 0];
daisy2_scale = 0.15;

daisy3_center = [12, -60, 0];
daisy3_scale = 0.24;

module message() {
  translate([0, 8, 0]) {
    translate([-40, 5, 0]) mytext("Happy");
    translate([-33, -20, 0]) mytext("Birthday,");
    translate([-26, -40, 0]) mytext("Ashia!");
  }
}

module daisy() {
  height = 15;
  petals = 10;
  radius = 100;
  petal_radius = 18;
  
  for (t = [0:(petals-1)]) {
    rotate([0, 0, t*(360/petals)]) {
      hull() {
        translate([radius-petal_radius, 0, 0]) circle(petal_radius);
        translate([10, 0, 0]) circle(eps);
      }
    }
  }
  circle(30);
}

module blank_layer() {
  translate([0, 0, layer_thickness/2])
    cube([90, 120, layer_thickness], center=true);
}

module engrave() {
  morph([
    [-eps, [0]],
    [layer_thickness, [0.7]],
    [layer_thickness+1, [0.7]],
  ])
    offset(r=$m[0])
      children();
}

module layer1() {
  difference() {
    blank_layer();
    
    // Message.
    engrave() message();
    
    engrave() 
      translate(daisy1_center - [0, 0, eps])
        scale([daisy1_scale, daisy1_scale, 1])
          daisy();
    
    engrave()
      translate(daisy2_center - [0, 0, eps])
        scale([daisy2_scale, daisy2_scale, 1])
          daisy();
    
    engrave()
      translate(daisy3_center - [0, 0, eps])
        scale([daisy3_scale, daisy3_scale, 1])
          daisy();
  }
}

module layer2() {
  blank_layer();
}

translate([0, 0, layer_thickness]) layer1();
color("yellow") layer2();