include <common.scad>

// Clearances are expressed as the total across both sides of a joint.
snug = 0.15;  // Snug, but can still move.
loose = 0.3;  // Moves easily.

$fa = 4;
$fs = 0.1;
eps = 0.001;

tube_wall = 3;
tube_id = spring_od + loose;
tube_od = tube_id + 2*tube_wall;
axle_diameter = 5;

// 550 paracord.
string_diameter = 3;

wheel_diameter = axle_diameter + 2*spring_od + 3*tube_wall;
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

// The axle is split into two pieces glued end-to-end into the follower.
axle_split = 1.5;

// 'piece' should be 1 or 2. 1 is the longer piece.
module axle(piece) {
  length =
    piece == 1
    ? wheel_thickness + 2*axle_plate_thickness + axle_cap_thickness - axle_split
    : axle_cap_thickness + axle_split;
  
  spool(length, axle_diameter/2, -small_flare);

  intersection() {
    spool(axle_cap_thickness, axle_cap_diameter/2, -small_flare);
    
    // Make sure the cap fits between the fingers.
    cube([axle_cap_diameter*0.85, 30, 6], center=true);
  }
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
// Make sure the tube is not close to rubbing against the wheel, even if
// the follower wiggles a bit.
tube_y_offset = tube_od/2 + wheel_thickness/2 + 1;

module tubes() {
  plate_thickness = 4;

  // The plate.
  translate([0, 0, -plate_thickness]) {
    difference() {
      linear_extrude(plate_thickness + eps)
        hull()
          for (a = [-1, 1], b = [-1, 1])
            scale([a, b, 1])
              translate([tube_x_offset, tube_y_offset, 0])
                circle(d=tube_od);
          
      // Side cutouts for the string.
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([tube_x_offset + tube_od/2, 0, 0])
            rotate([0, 0, 45])
              translate([-6, -6, -1])
                cube([12, 12, plate_thickness+2]);
    }
  }
  
  for (a = [-1, 1], b = [-1, 1])
    scale([a, b, 1])
      translate([tube_x_offset, tube_y_offset, 0])
        tube();
  
  // Join tubes where possible, for reinforcement.
  for (a = [-1, 1])
    scale([1, a, 1])
      translate([0, tube_y_offset+1, tube_length/2])
        cube([axle_cap_diameter+2*tube_wall, tube_wall, tube_length], center=true);
}

wheel_inset = 1;

module follower() {
  finger_thickness = tube_wall_slot_thickness - loose;
  
  // Follower ends which ride up and down the tubes on top of the springs.
  for (a = [-1, 1], b = [-1, 1]) {
    scale([a, b, 1]) {
      translate([tube_x_offset, tube_y_offset, 0]) {
        difference() {
          spool(follower_length, spring_od/2, -small_flare);
          
          // Mass-saving voids in the end of the follower.
          void_height = follower_length-3;
          cone_height = 3;
          translate([0, 0, -eps]) {
            spool(void_height-cone_height, spring_od/2-2.5, small_flare);
            translate([0, 0, void_height-cone_height-eps])
              cylinder(cone_height, spring_od/2-2.5, 2);
          }
        }
      }
    }
  }
  
  module core_shell() {
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
    //
    // TODO: mold the tail part of this to the outsides of the tubes, to give some extra
    // guidance for the sliding motion.
    plate_thickness = wheel_thickness + 2*axle_plate_thickness;
    plate_width = 15;
    translate([-plate_width/2, -plate_thickness/2, 0])
      cube_spool([
        plate_width,
        plate_thickness,
        follower_length + spring_min_length
      ], -small_flare);
  }
  
  difference() {
    core_shell();
    
    // Cutout for the wheel.
    translate([0, (wheel_thickness+loose)/2, axle_cap_diameter/2+wheel_inset])
      rotate([90, 0, 0])
        // Make this extra loose, so the wheel is sure not to rub.
        cylinder(wheel_thickness+loose, d=wheel_diameter+1);
    
    // Chamfer against build plate.
    chamfer_cube = (wheel_thickness+loose + small_flare*2)/sqrt(2);
    rotate([45, 0, 0])
      cube([20, chamfer_cube, chamfer_cube], center=true);
    
    // Holes for the axle.
    translate([0, 20, axle_cap_diameter/2+wheel_inset])
      rotate([90, 0, 0])
        linear_extrude(40)
          octagon(axle_diameter+snug);
  }
}

// 0: Relaxed.
// 1: Max tension.
module preview(state=1) {
  translate([0, state == 0 ? spring_min_length - spring_max_length : 0, 0]) {
    translate([0, -axle_cap_diameter/2-wheel_inset, 0]) {
      translate([0, 0, -wheel_thickness/2])
        wheel();

      translate([0, 0, wheel_thickness/2 + axle_plate_thickness + axle_cap_thickness])
        scale([1, 1, -1]) axle(1);
      translate([0, 0, -wheel_thickness/2 - axle_plate_thickness - axle_cap_thickness])
        axle(2);
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

tubes();