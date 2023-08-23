$fa = 6;
$fs = 0.2;
eps = 0.001;

// Use a larger value for faster rendering.
$zstep = 0.2;

// An inward chamfer sufficient to prevent elephant's foot.
foot = 0.4;

// FINDINGS FROM CLEARANCE TEST
//
// Consider a vertical hole of width X, a layer height of 0.2, and a vertical
// post.
//   * A post of diameter X will not fit in.
//   * A post of diameter X-0.1 will fit in, but is very hard to slide in or out.
//     This is probably due mostly to the transverse grain of the print.
//     It will rotate, but with some resistance.
//   * A post of diameter X-0.2 slides in and out easily. It rotates easily, but
//     still has noticeable resistance at some points.
//   * A post of diameter X-0.3 rotates freely. It also has noticeable play
//     from side to side.
//
// Clearances are expressed as the total across both sides of a joint.
tight = 0.1;  // Intended for stationary joints.
snug = 0.2;   // Moves, but with some resistance.
loose = 0.3;  // Free movement.
extra_loose = 0.4;

// A brim is a 0.2mm layer printed near an edge which is likely to warp.
// The edge should be chamfered outwards at 45 degrees. The brim should
// be placed this far from the bottom of the edge, so it barely touches
// the chamfer.
brim_offset = 0.3;

// Menards 5/8 x 2-3/4 x 0.04 WG compression spring.
spring_od = 5/8 * 25.4;
// Subtract 10 from the relaxed length so everything is slightly tensioned
// all the time.
spring_max_length = 2.75 * 25.4 - 10;
spring_min_length = 16;  // Approximate.

// Menards 1/4 inch aluminum rod.
roller_diameter = 6.7;

// 550 paracord.
string_diameter = 4;

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
  q = 45;
  
  intersection() {
    // Add 0.2 (one print layer) in case the bridge is messy and hangs
    // down.
    square(2*r+0.2, center=true);
    hull() {
      circle(r);
      for (a = [-1, 1])
        translate([0, a*r/cos(q), 0])
          square(eps, center=true);
    }
  }
}

// Depth of the sockets used as glue aids.
socket_depth = 5;

module socket() {
  translate([-1.5, -1.5, -eps])
    flare_cube([3, 3, socket_depth], -foot);
}

module lug() {
  flare_cube([3-snug, 3-snug, 2*socket_depth-2], foot);
}

// Nerf darts are 0.50 cal.
dart_diameter = 12.7;
dart_length = 72;
