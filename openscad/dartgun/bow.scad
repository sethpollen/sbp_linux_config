// Clearances are expressed as the total across both sides of a joint.
snug = 0.2;  // Snug, but can still move.
loose = 0.4;  // Moves easily.

$fa = 5;
$fs = 0.2;
eps = 0.001;

// Menards 5/8 x 2-3/4 x 0.04 WG compression spring.
spring_od = 5/8 * 25.4;
// Relaxed length.
spring_max_length = 2.75 * 25.4;
spring_min_length = 16;  // Approximate.

tube_wall = 3;
tube_id = spring_od + loose;
tube_od = tube_id + 2*tube_wall;
axle_diameter = 5;

// 550 paracord.
string_diameter = 3;

wheel_diameter = axle_diameter + 2*spring_od + 4*tube_wall;
wheel_thickness = string_diameter + 1.5;

axle_plate_thickness = 4;

axle_cap_thickness = 2;
axle_cap_diameter = axle_diameter + 3;

// How much overlap between the tube and the spring follower when the spring
// is at its max length. This should be fairly large to keep the follower
// from getting cocked in the channels.
follower_length = spring_od;

tube_length = spring_max_length + follower_length;
tube_wall_slot_thickness = 5;

module octagon(diameter) {
  intersection_for(a = [0, 45])
    rotate([0, 0, a])
      square(diameter, center=true);
}

// A cylinder or cube with a flared bottom ends, useful for dealing with
// elephant's foot on pins or holes.
small_flare = 0.3;
module spool(height, radius, flare) {
  translate([0, 0, abs(flare)-eps])
    cylinder(height-abs(flare)+eps, radius, radius);
  linear_extrude(abs(flare), scale=radius/(radius+flare))
    circle(radius+flare);
}

// Like spool, but for cubes.
module cube_spool(dims, flare) {
  translate([0, 0, abs(flare)-eps])
    cube([dims.x, dims.y, dims.z - abs(flare) + eps]);

  translate([dims.x/2, dims.y/2, 0])
    linear_extrude(abs(flare), scale=[dims.x/(dims.x+2*flare), dims.y/(dims.y+2*flare)])
      translate([-(dims.x+2*flare)/2, -(dims.y+2*flare)/2, abs(flare)-eps])
        square([dims.x+2*flare, dims.y+2*flare]);
}

module wheel() {
  difference() {
    rotate_extrude() {
      difference() {
        square([wheel_diameter/2, wheel_thickness]);
        translate([wheel_diameter/2 + string_diameter*0.17, wheel_thickness/2])
          octagon(string_diameter);
      }
    }
    
    translate([0, 0, -eps])
      spool(wheel_thickness+2*eps, axle_diameter/2 + snug, small_flare);
  }
}

module axle() {
  spool(wheel_thickness + 2*axle_plate_thickness + axle_cap_thickness, axle_diameter/2, -small_flare);
  spool(axle_cap_thickness, axle_cap_diameter/2, -small_flare);
}

module tube() {
  linear_extrude(tube_length) {
    difference() {
      circle(d=tube_od);
      circle(d=tube_id);
    
      rotate([0, 0, 225])
        translate([tube_id*0.4, -tube_wall_slot_thickness/2, -1])
          square([tube_wall*2.5, tube_wall_slot_thickness]);
    }
  }
}

tube_x_offset = tube_od/2 + axle_cap_diameter/2;
tube_y_offset = tube_od/2 + wheel_thickness/2 + loose/2;

module tubes() {
  plate_thickness = 4;

  translate([0, 0, -plate_thickness])
    linear_extrude(plate_thickness + eps)
      hull()
        for (a = [-1, 1], b = [-1, 1])
          scale([a, b, 1])
            translate([tube_x_offset, tube_y_offset, 0])
              circle(d=tube_od);
  
  for (a = [-1, 1], b = [-1, 1])
    scale([a, b, 1])
      translate([tube_x_offset, tube_y_offset, 0])
        tube();
}

module follower() {
  finger_thickness = tube_wall_slot_thickness - loose;
  
  // Follower ends which ride up and down the tubes on top of the springs.
  for (a = [-1, 1], b = [-1, 1])
    scale([a, b, 1])
      translate([tube_x_offset, tube_y_offset, 0])
        spool(follower_length, spring_od/2, -small_flare);
  
  // Fingers which fit into the tube wall slots.
  for (a = [-1, 1], b = [-1, 1]) {
    scale([a, b, 1]) {
      intersection() {
        translate([tube_x_offset, tube_y_offset, 0])
          rotate([0, 0, 225])
            translate([tube_id*0.4, -finger_thickness/2, 0])
              cube_spool([50, finger_thickness, follower_length], -small_flare);
        
        translate([-25, 0, 0])
          cube([50, 50, follower_length]);
      }
    }
  }
  
  // Plate with sockets for the wheel.
  plate_thickness = wheel_thickness + 2*axle_plate_thickness;
  plate_width = 15;
  translate([-plate_width/2, -plate_thickness/2, 0])
    cube_spool([
      plate_width,
      plate_thickness,
      follower_length + spring_min_length
    ], -small_flare);
}

// 0: Relaxed.
// 1: Max tension.
module preview(state=1) {
  translate([0, state == 0 ? spring_min_length - spring_max_length : 0, 0]) {
    translate([0, -axle_cap_diameter/2, 0]) {
      translate([0, 0, -wheel_thickness/2])
        wheel();

      translate([0, 0, wheel_thickness/2 + axle_plate_thickness + axle_cap_thickness])
        scale([1, 1, -1]) axle();
    }

    translate([0, -tube_length, 0])
      rotate([-90, 0, 0])
        translate([0, 0, tube_length])
          color("red")
            scale([1, 1, -1])
              follower();
  }
  
  translate([0, -tube_length, 0])
    rotate([-90, 0, 0])
      tubes();
}

preview();