$fa = 5;
$fs = 0.2;
eps = 0.001;

// An inward chamfer sufficient to prevent elephant's foot.
foot = 0.4;

module octagon(diameter) {
  intersection_for(a = [0, 45])
    rotate([0, 0, a])
      square(diameter, center=true);
}

// A cylinder with a chamfered or flared bottom end, useful for dealing
// with elephant's foot on pins or holes.
module flare_cylinder(height, radius, flare) {
  translate([0, 0, abs(flare)-eps])
    cylinder(height-abs(flare)+eps, radius, radius);

  linear_extrude(abs(flare), scale=radius/(radius-flare))
    circle(radius-flare);
}

// A cube with a chamfered or flared bottom end, useful for dealing
// with elephant's foot on pins or holes.
module flare_cube(dims, flare) {
  translate([0, 0, abs(flare)-eps])
    cube([dims.x, dims.y, dims.z - abs(flare) + eps]);

  translate([dims.x/2, dims.y/2, 0])
    linear_extrude(abs(flare), scale=[dims.x/(dims.x-2*flare), dims.y/(dims.y-2*flare)])
      translate([-(dims.x-2*flare)/2, -(dims.y-2*flare)/2, abs(flare)-eps])
        square([dims.x-2*flare, dims.y-2*flare]);
}

// An approximate circle which can be printed on its side.
module circle_ish(r) {
  // Safe overhang angle.
  s = 40;
  
  intersection() {
    // Add 0.2 (one print layer) in case the bridge is messy and hangs
    // down.
    square(2*r+0.2, center=true);
    union() {
      circle(r);
      polygon(r*[
        [sin(s), cos(s)],
        [0, norm([1, norm([sin(s), 1-cos(s)])])],
        [-sin(s), cos(s)],
        [-sin(s), -cos(s)],
        [0, -norm([1, norm([sin(s), 1-cos(s)])])],
        [sin(s), -cos(s)],
      ]);
    }
  }
}
