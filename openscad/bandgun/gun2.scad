include <common.scad>
use <../morph.scad>

// Convention is to point the gun barrel along the Y axis, in the positive
// direction.

// TODO: suggest a 30 degree rotation for lug interlock, like in interlock.scad.

receiver_height = 9;
receiver_width = 22;
receiver_length = 110;

slide_channel_width = 10;
slide_width = slide_channel_width - 2*loose_clearance;

// Z-distance from top of receiver to center of rails.
// TODO: check this in projection
slide_rail_drop = 4;

plate_thickness = 2;
plate_length = 39;

release_slide_length = 25;

trigger_slide_length = 45;

// TODO: Remove "thick"
thick_spring_channel_center_inset = 1.5;
thick_spring_wire_radius = 0.4;

// TODO: remove
thin_spring_channel_center_inset = 3.5;
thin_spring_wire_radius = 0.3;

spring_post_radius = 2;

// Distance between the back of the sliding channel and the back of the reciver exterior.
receiver_back_offset = 15;

module spring_post(post_radius, wire_radius) {
  morph([
    [0, [0]],
    [wire_radius*2, [0]],
    [wire_radius*2+1.3, [1.7]],
  ])
    translate([0, $m[0], 0])
      circle(post_radius);
}

module thick_spring_post() {
  spring_post(spring_post_radius, thick_spring_wire_radius);
}

// TODO: remove
module thin_spring_post() {
  spring_post(1.5, thin_spring_wire_radius);
}

// A generic sliding block that fits into the receiver channel and has a
// spring cavity and spring post.
module slide(length, spring_channel_length, bottom_offset) {
  // Take off clearance from the bottom.
  height = receiver_height - bottom_offset - loose_clearance;

  difference() {
    // Main exterior.
    translate([-slide_width/2, -length, 0])
      cube([slide_width, length, height]);
    
    // Chamfer the edges so that any elephant foot doesn't interfere with
    // the sliding.
    for (x = slide_width/2 * [-1, 1], z = [0, height])
      translate([x, 0, z])
        square_rail(1000, major_radius=0.5);
    for (z = [0, height])
      translate([0, -length, z])
        rotate([0, 0, 90])
          square_rail(1000, major_radius=0.5);
    
    // Spring channel: Rectangular top section.
    translate([
      -3.5,
      -length + spring_channel_length + 8,
      height - thick_spring_channel_center_inset - thick_spring_wire_radius
    ])
      scale([1, -1, 1])
        cube([7, 1000, 1000]);

    // Spring channel: Round bottom section.
    translate([
      0,
      -length + spring_channel_length,
      height - thick_spring_channel_center_inset
    ])
      rotate([90, 0, 0])
        cylinder(1000, 3.5, 3.5);
  }

  // Spring post.
  translate([
    0,
    -length + spring_channel_length + spring_post_radius,
    height - thick_spring_channel_center_inset - thick_spring_wire_radius-eps
  ])
    thick_spring_post();

  // Rails.
  for (x = slide_width/2 * [-1, 1])
    translate([x, -length/2, height + loose_clearance - slide_rail_drop])
      square_rail(length);
}

// Front and back lugs for the receiver and release.
module outer_lugs(bottom_offset, flip_print_aid=false) {
  lug_width = 4;
  lug_radius = 2.5;
  height = receiver_height - bottom_offset;
  end_chamfer = 0.5;
  
  // The lugs themselves, which extends beyond the receiver in the X dimension.
  translate([0, 3.5, height - lug_radius])
    hull()
      for (a = [-1, 1])
        translate([(receiver_width/2 + lug_width - eps)*a, 0, 0])
          rotate([0, a*90, 0])
            translate([0, 0, -end_chamfer])
              linear_extrude(end_chamfer, scale=(lug_radius-end_chamfer)/lug_radius)
                circle(lug_radius);
      
  // A printing aid on the part of the lug which need not be rounded.
  translate([0, 3.5, height-lug_radius]) {
    rotate([0, flip_print_aid ? 180 : 0, 0]) {
      difference() {
        hull()
          for (a = [-1, 1])
            scale([a, 1, 1])
              translate([(receiver_width/2 + lug_width - eps), 0, 0])
                rotate([0, 90, 0])
                  translate([0, 0, -end_chamfer])
                    linear_extrude(end_chamfer, scale=(lug_radius-end_chamfer)/lug_radius)
                      square(lug_radius);
        
        // Chamfer the front edge.
        translate([0, lug_radius, -lug_radius])
          rotate([0, 0, 90])
            square_rail(1000, 0.5);
      }
    }
  }
      
  // The body on which the lugs are mounted, which has the same width as the
  // receiver.
  difference() {
    translate([0, 0, height/2]) {
      hull() {
        for (a = [-1, 1]) {
          scale([a, 1, 1]) {
            translate([receiver_width/2-1, 0, 0]) {
              rotate([0, 90, 0]) {
                linear_extrude(1, scale=[1, 0.9]) {
                  hull() {
                    for (a = [-1, 1]) {
                      translate([a*(height/2-lug_radius), 3.5, 0])
                        circle(lug_radius);
                      translate([a*(height/2-1), 1, 0])
                        square(2, center=true);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    
    // Chamfers.
    for (x = receiver_width/2 * [-1, 1]) {
      for (z = [0, height])
        translate([x, 0, z])
          square_rail(1000, 0.5);
      translate([x, 0, 0])
        rotate([90, 0, 0])
          square_rail(1000, 0.5);
    }
  }
}

// The receiver encloses the two sliding parts and has lugs for attaching
// the magazine. It is printed in a single piece with the grip.
module receiver() {  
  difference() {
    // Exterior.
    translate([-receiver_width/2, 0, 0])
      cube([receiver_width, receiver_length, receiver_height]);
    
    // Inner channel for sliding parts.
    translate([-slide_channel_width/2, receiver_back_offset, -1])
      cube([slide_channel_width, 1000, 1000]);
    
    // Rail cavities for sliding parts.
    for (x = slide_channel_width/2 * [-1, 1])
      translate([x, 500+receiver_back_offset, receiver_height/2+1])
        square_rail(1000);
    
    // Recess for plate.
    translate([-500, receiver_length-plate_length, -1])
      cube([1000, 1000, plate_thickness+1]);
    
    // Rail cavities for plate placement guides.
    for (x = receiver_width*3/8 * [-1, 1])
      translate([x, receiver_length-(plate_length+2)/2, 2])
        square_rail(plate_length-2);

    // Chamfers against built plate for elephant foot.
    for (x = slide_channel_width/2 * [-1, 1])
      translate([x, 500+receiver_back_offset, receiver_height])
        square_rail(1000, major_radius=0.5);
    for (x = receiver_width/2 * [-1, 1])
      translate([x, 0, receiver_height])
        square_rail(1000, major_radius=0.5);
    
    // Front face side chamfers, where it meets the front lugs.
    for (x = receiver_width/2 * [-1, 1])
      translate([x, receiver_length, 0])
        rotate([90, 0, 0])
          square_rail(1000, major_radius=0.4);
  }
    
  // Rear lugs.
  translate([0, 1, 0])
    scale([1, -1, 1])
      outer_lugs(0, true);
}

// The front sliding part, which holds the mag in place.
module release() {
  slide(release_slide_length,
    // TODO: tune spring tension
    11.3, plate_thickness);
  outer_lugs(plate_thickness + loose_clearance);

  // Help the supports adhere to the build plate.  
  linear_extrude(0.5)
    for (x = 13.8 * [-1, 1])
      translate([x, 4, 0])
        square([5, 8], center=true);
}

// The rear sliding part, which pushes the bands up the back of the mag.
// TODO: use slide()
module trigger() {
  height = receiver_height - loose_clearance;
  
  // Slide.
  difference() {
    translate([-slide_width/2, -trigger_slide_length, 0])
      cube([slide_width, trigger_slide_length, height]);
    
    // Chamfer the edges so that any elephant foot doesn't interfere with
    // the sliding.
    for (x = slide_width/2 * [-1, 1], z = [0, height])
      translate([x, 0, z])
        square_rail(1000, major_radius=0.5);
    for (z = [0, height])
      translate([0, -trigger_slide_length, z])
        rotate([0, 0, 90])
          square_rail(1000, major_radius=0.5);
    
    // Spring channel.
    translate([
      -3,
      -trigger_slide_length-eps,
      height-thin_spring_channel_center_inset-thin_spring_wire_radius
    ])
      cube([6, trigger_slide_length-4, 1000]);

    translate([
      0,
      30-trigger_slide_length-eps,
      height-thin_spring_channel_center_inset
    ])
      rotate([90, 0, 0])
        cylinder(1000, 3, 3);
  }

  // Spring post.
  translate([
    0,
    -13.5,
    height-thin_spring_channel_center_inset-thin_spring_wire_radius-eps
  ])
    thin_spring_post();

  // Rails.
  for (x = slide_width/2 * [-1, 1])
    translate([x, -trigger_slide_length/2, receiver_height/2+1])
      square_rail(trigger_slide_length);
  
  // TODO: replace this with a real trigger shape.
  morph([
    [-30, [1,   0.5]],
    [-24, [0.7, 0.5]],
    [-15,  [0.7, 0.5]],
    [eps, [1,   1  ]],
  ])
    translate([-8.4*$m[0]/2, -(1+$m[1])*(trigger_slide_length)/2, 0])
      square([8.4*$m[0], (trigger_slide_length)*$m[1]]);
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
        translate([x, (plate_length-3)/2, 2])
          square_rail(plate_length-3);
    }
  
    // Front bottom chamfer.
    translate([0, plate_length, 0])
      rotate([0, 0, 90])
        square_rail(1000);
    
    // Other bottom chamfers, just enough to counter elephant's foot.
    for (x = receiver_width/2 * [-1, 1])
      translate([x, 0, 0])
        square_rail(1000, major_radius=0.3);
    rotate([0, 0, 90])
      square_rail(1000, major_radius=0.3);
    
    // Slight depressions at corners, to counteract the natural curl during printing.
    translate([0, plate_length/2, 0])
      for (a = [0, 90, 180, 270])
        rotate([0, 0, a])
          translate([plate_length/2, -receiver_width/2, plate_thickness])
            rotate([0, 0, -45])
              square_rail(1000, major_radius=0.2);
  }
  
  // Platform at the back for the spring posts.
  platform_length = plate_length-release_slide_length-0.5;
  translate([-slide_width/2, 0, plate_thickness-eps]) {
    // The front and back of the platform have different heights for the different
    // springs.
    translate([0, platform_length*0.6, -eps])
      cube([
        slide_width,
        platform_length*0.4,
        receiver_height-plate_thickness-thick_spring_channel_center_inset-thick_spring_wire_radius
      ]);
    cube([
      slide_width,
      platform_length,
      receiver_height-plate_thickness-thin_spring_channel_center_inset-thin_spring_wire_radius
    ]);
  }
   
  // Front spring post.
  translate([
    0,
    11.5,
    receiver_height-thick_spring_channel_center_inset-thick_spring_wire_radius-eps
  ])
    scale([1, -1, 1])
      thick_spring_post();
  
  // Rear spring post.
  translate([
    0,
    1.5,
    receiver_height-thin_spring_channel_center_inset-thin_spring_wire_radius-eps
  ])
    thin_spring_post();  
}

module preview() {
  color("yellow") receiver();
  color("red") translate([0, receiver_length+loose_clearance, plate_thickness+loose_clearance]) release();
  color("blue") translate([0, receiver_length-plate_length, 0]) plate();
  color("orange") translate([0, receiver_back_offset+10, 0]) scale([1, -1, 1]) trigger();
}

module print() {
  translate([-40, 0, receiver_height])
    scale([1, 1, -1])
      receiver();

  release();
  
  translate([0, 20, 0])
    plate();
  
  translate([-30, -15, 30])
    trigger();
}

preview();