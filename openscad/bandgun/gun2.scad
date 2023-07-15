include <common.scad>
use <morph.scad>

// Convention is to point the gun barrel along the Y axis, in the positive
// direction.

// TODO: suggest a 30 degree rotation for lug interlock, like in interlock.scad.

lug_radius = 2.5;
lug_width = 4;
lug_chamfer = 0.7;

receiver_height = 9;
receiver_width = 22;
receiver_length = 60; // TODO: 130

slide_channel_width = 10;
slide_width = slide_channel_width - 2*loose_clearance;

plate_thickness = 2;
plate_length = 40;

release_slide_length = 30;

thick_spring_channel_center_inset = 1.5;
thick_spring_wire_radius = 0.4;

// A bar for mag retention lugs. Centered on the X axis.
module lug_bar() {
  width = receiver_width+2*(lug_width-lug_chamfer);
  translate([-width/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(width, lug_radius, lug_radius);
  
  // Chamfer cones.
  for (a = [-1, 1])
    translate([(receiver_width/2-eps)*a, 0, 0])
      rotate([0, a*90, 0])
        translate([0, 0, lug_width-lug_chamfer-eps]) 
          linear_extrude(lug_chamfer, scale=(lug_radius-lug_chamfer)/lug_radius)
            circle(lug_radius);
}

// The receiver encloses the two sliding parts and has lugs for attaching
// the magazine. It is printed in a single piece with the grip.
module receiver() {
  back_offset = 15;
  
  difference() {
    // Exterior.
    union() {
      difference() {
        translate([-receiver_width/2, 0, 0])
          cube([receiver_width, receiver_length, receiver_height]);
        
        // Rear face top and bottom chamfers. These are bit cutouts; we'll fill them
        // in with cylinders later.
        for (z = [0, receiver_height])
          translate([-100, lug_radius, z])
            rotate([135, 0, 0])
              cube([1000, 1000, 1000]);
      }
      
      // Rear bottom edge, rounded to match the lugs.
      translate([-receiver_width/2, lug_radius, lug_radius]) {
        rotate([0, 90, 0])
          cylinder(receiver_width, lug_radius, lug_radius);
      }
    }
    
    // Inner channel for sliding parts.
    translate([-slide_channel_width/2, back_offset, -1])
      cube([slide_channel_width, 1000, 1000]);
    
    // Rail cavities for sliding parts.
    for (x = slide_channel_width/2 * [-1, 1])
      translate([x, 500+back_offset, receiver_height/2+1])
        square_rail(1000);
    
    // Recess for plate.
    translate([-500, receiver_length-plate_length, -1])
      cube([1000, 1000, plate_thickness+1]);
    
    // Rail cavities for plate placement guides.
    for (x = receiver_width*3/8 * [-1, 1])
      translate([x, 500+receiver_length-plate_length, 2])
        square_rail(1000);
    
    // Rear face side chamfers.
    for (x = receiver_width/2 * [-1, 1])
      translate([x, 0, 0])
        rotate([90, 0, 0])
          square_rail(1000);
  }
    
  // Rear lugs.
  translate([0, lug_radius, receiver_height-lug_radius])
    lug_bar();
}

module spring_post(post_radius, wire_radius) {
  morph([
    [0, [0]],
    [wire_radius*2, [0]],
    [wire_radius*2+1.3, [1.7]],
  ])
    translate([0, $m[0], 0])
      circle(post_radius);
}

// The front sliding part, which holds the mag in place.
module release() {
  height = receiver_height - plate_thickness - loose_clearance;

  // Slide.
  difference() {
    union() {
      translate([-slide_width/2, -release_slide_length, 0])
        cube([slide_width, release_slide_length, height]);
      
      // Slight extension forward into the lug bar.
      translate([-slide_width/2, -eps, height-lug_radius*2])
        cube([slide_width, lug_radius, lug_radius*2]);
      
      // Feet to rest against receiver.
      translate([-(slide_width+10)/2, -eps, height-4])
        cube([slide_width+10, lug_radius, 3]);
    }
    
    // Chamfer the edges so that any elephant foot doesn't interfere with
    // the sliding.
    for (x = slide_width/2 * [-1, 1], z = [0, height])
      translate([x, 0, z])
        square_rail(1000, major_radius=0.5);
    for (z = [0, height])
      translate([0, -release_slide_length, z])
        rotate([0, 0, 90])
          square_rail(1000, major_radius=0.5);
    
    // Spring channel.
    translate([
      -3.5,
      -release_slide_length-eps,
      height-thick_spring_channel_center_inset-thick_spring_wire_radius
    ])
      cube([7, 22, 1000]);

    translate([
      0,
      12.5-release_slide_length-eps,
      height-thick_spring_channel_center_inset
    ])
      rotate([90, 0, 0])
        cylinder(12.5, 3.5, 3.5);
  }

  // Spring post.
  translate([
    0,
    -16,
    height-thick_spring_channel_center_inset-thick_spring_wire_radius-eps
  ])
    spring_post(1.5, thick_spring_wire_radius);

  // Rails.
  for (x = slide_width/2 * [-1, 1])
    translate([x, 1-release_slide_length/2, (height-loose_clearance)/2])
      square_rail(release_slide_length+2);
    
  // Front lugs.
  translate([0, lug_radius, height-lug_radius])
    lug_bar();

  // Help the supports adhere to the build plate.  
  linear_extrude(0.5) {
    hull()
      for (x = 15 * [-1, 1])
        translate([x, 3, 0])
          circle(2.5);
    
    for (a = [-1, 1])
      hull()
        for (x = [8*a, 14*a])
          translate([x, 0, 0])
            circle(2.5);
  }
}

// Glued under the front of the receiver to maintain the right spacing between the
// two sides.
module plate() {
  // The plate itself.
  difference() {
    union() {
      translate([-receiver_width/2, 0, 0])
        cube([receiver_width, plate_length, plate_thickness]);
      
      // Placement guide rails.
      for (x = receiver_width*3/8 * [-1, 1])
        translate([x, plate_length/2, 2])
          square_rail(plate_length);
    }
  
    // Front bottom chamfer.
    translate([0, plate_length, 0])
      rotate([0, 0, 90])
        square_rail(1000);
    
    // Other bottom chamfers, just enough to counter elephant's foot.
    for (x = receiver_width/2 * [-1, 1])
      translate([x, 0, 0])
        square_rail(1000, major_radius=0.5);
    rotate([0, 0, 90])
      square_rail(1000, major_radius=0.5);
  }
  
  // Platform at the back for the spring posts.
  translate([-slide_width/2, 0, plate_thickness-eps])
    cube([
      slide_width,
      plate_length-release_slide_length-0.5,
      receiver_height-plate_thickness-thick_spring_channel_center_inset-thick_spring_wire_radius
    ]);
  
  // Front spring post.
  translate([
    0,
    8,
    receiver_height-thick_spring_channel_center_inset-thick_spring_wire_radius-eps
  ])
    scale([1, -1, 1])
      spring_post(1.5, thick_spring_wire_radius);
}

module preview() {
  color("yellow") receiver();
  color("red") translate([0, receiver_length+loose_clearance, plate_thickness+loose_clearance]) release();
  color("blue") translate([0, receiver_length-plate_length, 0]) plate();
}

module print() {
  translate([-40, 0, receiver_height])
    scale([1, 1, -1])
      receiver();

  release();
  
  translate([0, 20, 0])
    plate();
}

release();