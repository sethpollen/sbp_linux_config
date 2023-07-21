include <common.scad>
use <../morph.scad>

// Convention is to point the gun barrel along the Y axis, in the positive
// direction.

// TODO: suggest a 30 degree rotation for lug interlock, like in interlock.scad.

receiver_height = 9;
receiver_width = 22;

slide_channel_width = 10;

// Z-distance from top of receiver to center of rails.
slide_rail_drop = 4;

release_slide_length = 25;
trigger_slide_length = 60;

plate_thickness = 2;
plate_length = release_slide_length+13;

// Distance between the back of the sliding channel and the back of the receiver exterior.
receiver_back_offset = 10;
trigger_travel = 10;

receiver_length = plate_length + trigger_slide_length + trigger_travel + receiver_back_offset;

spring_channel_center_inset = 1.5;
spring_wire_radius = 0.4;

spring_post_radius = 2;

module spring_post() {
  morph([
    [0, [0]],
    [spring_wire_radius*2, [0]],
    [spring_wire_radius*2+1.3, [1.7]],
  ])
    translate([0, $m[0], 0])
      circle(spring_post_radius);
}

// A generic sliding block that fits into the receiver channel and has a
// spring cavity and spring post.
module slide(length, width_clearance, spring_channel_length, bottom_offset, chamfer_back=true) {
  height = receiver_height - bottom_offset;
  width = slide_channel_width - width_clearance;

  difference() {
    union() {
      // Main exterior.
      translate([-width/2, -length, 0])
        cube([width, length, height]);

      // Rails.
      for (x = width/2 * [-1, 1])
        translate([x, -length/2, height - slide_rail_drop])
          square_rail(length);
    }
    
    // Chamfer the edges so that any elephant foot doesn't interfere with
    // the sliding.
    for (x = width/2 * [-1, 1], z = [0, height])
      translate([x, 0, z])
        square_rail(1000, major_radius=0.5);
    for (z = [0, height])
      translate([0, -length, z])
        rotate([0, 0, 90])
          square_rail(1000, major_radius=0.5);
    
    // Chamfer the sides of the ends.
    for (a = [-1, 1])
      scale([a, 1, 1])
        translate([(width-1)/2, -length, 0])
          rotate([0, 0, -45])
            cube(10);
    
    if (chamfer_back) {
      // This is a more aggressive chamfer, in case the back of the slide channel
      // has binding edges on it. It's OK to give up some rail length, as
      // the trigger piece is long.
      for (a = [-1, 1])
        scale([a, 1, 1])
          translate([(width-2)/2, 0, 0])
            rotate([0, 0, -45])
              cube(10);
      for (z = [0, height])
        translate([0, 0, z])
          rotate([0, 0, 90])
            square_rail(1000);
    }
    
    // Spring channel: Rectangular top section.
    translate([
      -3.5,
      -length + spring_channel_length + 7,
      height - spring_channel_center_inset - spring_wire_radius
    ])
      scale([1, -1, 1])
        cube([7, 1000, 1000]);

    // Spring channel: Round bottom section.
    translate([
      0,
      -length + spring_channel_length,
      height - spring_channel_center_inset
    ])
      rotate([90, 0, 0])
        cylinder(1000, 3.5, 3.5);
  }
  
  // Spring post.
  translate([
    0,
    -length + spring_channel_length + spring_post_radius,
    height - spring_channel_center_inset - spring_wire_radius-eps
  ])
    spring_post();
}

// Front and back lugs for the receiver and release.
module outer_lugs(bottom_offset, flipped_print_aid=false) {
  lug_width = 4;
  lug_radius = 2.5;
  height = receiver_height - bottom_offset;
  end_chamfer = 0.5;
  
  // The lugs themselves, which extends beyond the receiver in the X dimension.
  translate([0, lug_radius+1, height - lug_radius])
    hull()
      for (a = [-1, 1])
        translate([(receiver_width/2 + lug_width - eps)*a, 0, 0])
          rotate([0, a*90, 0])
            translate([0, 0, -end_chamfer])
              linear_extrude(end_chamfer, scale=(lug_radius-end_chamfer)/lug_radius)
                circle(lug_radius);
  
  if (flipped_print_aid) {
    translate([-receiver_width/2-lug_width, lug_radius+0.5, height-lug_radius-0.5])
      chamfered_cube([receiver_width+lug_width*2, lug_radius+0.5, lug_radius+0.5], 0.5);
  } else {
    difference() {
      translate([-receiver_width/2-lug_width, lug_radius-0.5, 0])
        chamfered_cube([receiver_width+lug_width*2, lug_radius+1.5, height-lug_radius+0.5], 0.5);
      
      // We don't want the magazine lugs to actually rest against the print aid
      // (we want them tight against the receiver lugs). So cut out a cylinder
      // slightly wider than the magazine lugs, but centered where we expect the
      // magainze lugs to sit.
      bloat = 1.2;
      translate([0, lug_radius+1, height-lug_radius])
        rotate([-30, 0, 0])
          translate([-25, 0, -lug_radius*2])
            rotate([0, 90, 0])
              cylinder(50, lug_radius*bloat, lug_radius*bloat);
    }
  }
      
  // The body on which the lugs are mounted, which has the same width as the
  // receiver.
  translate([-receiver_width/2, 0, 0])
    chamfered_cube([receiver_width, lug_radius+1.5, height], 0.5);
  translate([-receiver_width/2, 0, 0])
    chamfered_cube([receiver_width, lug_radius*2+1, height-2], 0.5);
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
      translate([x, 500+receiver_back_offset, receiver_height-slide_rail_drop])
        square_rail(1000);
    
    // Recess for plate.
    translate([-500, receiver_length-plate_length, -1])
      cube([1000, 1000, plate_thickness+1]);
    
    // Rail cavities for plate placement guides.
    for (x = receiver_width*3/8 * [-1, 1])
      translate([x, receiver_length-(plate_length+2)/2, 2])
        square_rail(plate_length-2);

    // Chamfers against built plate for elephant foot.
    for (z = [0, receiver_height]) {
      for (x = slide_channel_width/2 * [-1, 1])
        translate([x, 500+receiver_back_offset, z])
          square_rail(1000, major_radius=0.5);
      for (x = receiver_width/2 * [-1, 1])
        translate([x, 0, z])
          square_rail(1000, major_radius=0.5);
    }
    translate([0, receiver_length, receiver_height])
      rotate([0, 0, 90])
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
      outer_lugs(0, flipped_print_aid=true);
}

// The front sliding part, which holds the mag in place.
module release() {
  // Distance between inner edges of end loops when the spring is relaxed.
  spring_length = 18;
  
  // TODO: tune
  spring_tension = 0.5;
  
  slide(
    release_slide_length,
    2*loose_clearance,
    spring_length + spring_tension - 4*spring_post_radius,
    plate_thickness + loose_clearance,
    chamfer_back=false
  );
  outer_lugs(plate_thickness + loose_clearance);
  
  // Avoid a chamfer channel on the top and bottom between the two pieces.
  fillet_width = slide_channel_width-2*loose_clearance;
  fillet_height = receiver_height - plate_thickness - loose_clearance;
  translate([-fillet_width/2, -1, 0])
    chamfered_cube([fillet_width, 3, fillet_height], 0.5);
}

// The rear sliding part, which pushes the bands up the back of the mag.
module trigger() {
  // Distance between inner edges of end loops when the spring is relaxed.
  spring_length = 43;
  
  // TODO: tune
  spring_tension = 5;

  slide(
    trigger_slide_length,
    // Add slightly more clearance. This spring is weaker, so we need to
    // take more care the slide doesn't bind in the channel.
    3*loose_clearance, // TODO: more?
    spring_length + spring_tension - 4*spring_post_radius,
    0
  );
  
  // TODO: remove this little grip
  translate([0, -8, 15])
    intersection_for (a = [0, 45])
      rotate([0, 0, a])
        cube([8, 8, 15], center=true);
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
    
    // Side chamfers to match the receiver.
    for (x = receiver_width/2 * [-1, 1])
      translate([x, 0, 0])
        square_rail(1000, major_radius=0.5);

    // Rear bottom chamfer, just enough to counter elephant's foot.
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
  platform_width = slide_channel_width - 2*loose_clearance;
  platform_length = plate_length - release_slide_length - 0.5;
  translate([-platform_width/2, 0, plate_thickness-eps])
    cube([
      platform_width,
      platform_length,
      receiver_height - plate_thickness - spring_channel_center_inset - spring_wire_radius
    ]);
   
  // Front spring post.
  translate([0, platform_length/2, 0])
    for (a = [-1, 1])
      scale([1, a, 1])
        translate([
          0,
          spring_post_radius - platform_length/2,
          receiver_height - spring_channel_center_inset - spring_wire_radius-eps
        ])
          spring_post();
}

module preview() {
  color("yellow") receiver();
  color("red") translate([0, receiver_length+loose_clearance, plate_thickness+loose_clearance]) release();
  color("blue") translate([0, receiver_length-plate_length, 0]) plate();
  color("orange") translate([0, receiver_back_offset+6, 0]) scale([1, -1, 1]) trigger();
}

module print() {
  translate([-35, -50, receiver_height])
    scale([1, 1, -1])
      receiver();

  release();
  
  translate([0, 20, 0])
    plate();
  
  translate([20, -10, 0])
    trigger();
}

release();
