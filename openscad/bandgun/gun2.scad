include <common.scad>
use <../morph.scad>

// Convention is to point the gun barrel along the Y axis, in the positive
// direction.

receiver_height = 9;
receiver_width = 22;

slide_channel_width = 10;

// Z-distance from top of receiver to center of rails.
slide_rail_drop = 4;

release_slide_length = 25;
trigger_slide_length = 70;

plate_thickness = 2;
plate_length = release_slide_length+13;

// Distance between the back of the sliding channel and the back of the receiver exterior.
receiver_back_offset = 3;
trigger_travel = 12;

receiver_length = plate_length + trigger_slide_length + trigger_travel + receiver_back_offset;

lug_width = 5;
lug_radius = 2.5;

// Center-to-center spacing. Add 1 for the extra offset on the release.
outer_lug_spacing = receiver_length + 2*lug_radius + 1;

spring_channel_center_inset = 1.5;
spring_wire_radius = 0.4;

spring_post_radius = 2;

action_width = 6;

mag_height = 25;

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
module slide(length, width, spring_channel_length, bottom_offset, chamfer_back=true) {
  height = receiver_height - bottom_offset - loose_clearance;

  difference() {
    union() {
      // Main exterior.
      translate([-width/2, -length, 0])
        cube([width, length, height]);

      // Rails.
      for (x = width/2 * [-1, 1])
        translate([x, -length/2, height + loose_clearance - slide_rail_drop])
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
  height = receiver_height - bottom_offset;
  end_chamfer = 0.5;
  lug_aid_height = receiver_height - plate_thickness - loose_clearance;
  
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
  }
  
  difference() {
    translate([-receiver_width/2-lug_width, lug_radius-0.5, height-lug_aid_height])
      chamfered_cube([receiver_width+lug_width*2, lug_radius+1.5, lug_aid_height-lug_radius+0.5], 0.5);
      
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
      
  // The body on which the lugs are mounted, which has the same width as the
  // receiver. It is 1mm longer than the lug bar.
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
  spring_tension = 0.5;
  
  width = slide_channel_width-2*loose_clearance;
  
  slide(
    release_slide_length,
    width,
    spring_length + spring_tension - 4*spring_post_radius,
    plate_thickness + loose_clearance,
    chamfer_back=false
  );
  outer_lugs(plate_thickness + loose_clearance);
  
  // Avoid a chamfer channel on the top and bottom between the two pieces.
  fillet_height = receiver_height - plate_thickness - loose_clearance;
  translate([-width/2, -1, 0])
    chamfered_cube([width, 3, fillet_height], 0.5);
}

// The rear sliding part, which pushes the bands up the back of the mag.
module trigger() {
  // Distance between inner edges of end loops when the spring is relaxed.
  spring_length = 43;
  spring_tension = 5;
  
  // Add slightly more clearance. This spring is weaker, so we need to
  // take more care the slide doesn't bind in the channel. This does make
  // for a pretty loose fit, but it's OK because we can put another sliding
  // rail on the trigger for more anchoring.
  width = slide_channel_width-3*loose_clearance;

  slide(
    trigger_slide_length,
    width,
    spring_length + spring_tension - 4*spring_post_radius,
    0
  );
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
      receiver_height - plate_thickness - loose_clearance - spring_channel_center_inset - spring_wire_radius
    ]);
   
  // Front spring post.
  translate([0, platform_length/2, 0])
    for (a = [-1, 1])
      scale([1, a, 1])
        translate([
          0,
          spring_post_radius - platform_length/2,
          receiver_height - loose_clearance - spring_channel_center_inset - spring_wire_radius-eps
        ])
          spring_post();
}

module mag() {
  // Add 0.3 to tension the release spring when the mag is in place.
  tensioned_lug_spacing = outer_lug_spacing + 0.3;
  width = receiver_width + 2*lug_width;
  
  mag_wall_thickness = 4;
  mag_plate_thickness = 2;
  mag_plate_length = tensioned_lug_spacing + 2*lug_radius;
  slot_width = action_width + 3*loose_clearance;

  difference() {
    translate([0, 0, loose_clearance]) {
      union() {
        // Front plate, which goes all the way across.
        translate([-width/2, 50-mag_plate_length/2, 0])
          chamfered_cube([
            width,
            mag_plate_length-50,
            mag_plate_thickness],
          1);
        
        // Front fill between walls.
        translate([-(slot_width+2*mag_wall_thickness)/2, 50-mag_plate_length/2, 0])
          chamfered_cube([
            slot_width+2*mag_wall_thickness,
            mag_plate_length-50,
            mag_height],
          1);
        
        // End print aids.
        translate([0, 0, mag_height-0.2])
          linear_extrude(0.2)
            for (y = (mag_plate_length/2+2) * [-1, 1])
              hull()
                for (x = 10 * [-1, 1])
                  translate([x, y, 0])
                    circle(3);
                
        // In back there is the trigger slot.
        for (a = [-1, 1]) {
          scale([a, 1, 1]) {
            translate([slot_width/2, -mag_plate_length/2, 0])
              chamfered_cube([
                (width-slot_width)/2,
                mag_plate_length, 
                mag_plate_thickness
              ], 1);
          
            // Trigger slot walls.
            translate([slot_width/2, -mag_plate_length/2, 0])
              chamfered_cube([
                mag_wall_thickness,
                mag_plate_length, 
                mag_height
              ], 1);
            
            // Outer walls.
            translate([width/2-mag_wall_thickness, -mag_plate_length/2, 0])
              chamfered_cube([
                mag_wall_thickness,
                mag_plate_length, 
                mag_height*0.7
              ], 1);
              
            // Print aids for outer walls.
            translate([13.2, 0, mag_height-0.2])
              linear_extrude(0.2)
                hull()
                  for (y = mag_plate_length/2 * [-1, 1])
                    translate([0, y, 0])
                      circle(6);
              
            // Make the trenches shallower towards the front.
            scale([1, -1, 1])
              morph([
                [mag_plate_thickness-1, [1]],
                [mag_plate_thickness + mag_height*0.4, [0]],
              ])
                translate([-13, -mag_plate_length/2, 0])
                  square([7, mag_plate_length*$m[0]]);
          }
        }
      }
    }
    
    // Spring channel.
    translate([
      0,
      // Close the channel in front.
      mag_plate_length/2 - 2*lug_radius - 5,
      -spring_channel_center_inset
    ])
      rotate([90, 0, 0])
        cylinder(1000, 3.8, 3.8);
  }
  
  // Side plates.
  side_plate_width = lug_width - loose_clearance;
  // Subtracting 2.5 just hits the tangent point between the lug cutout and tuck-under lug.
  side_plate_length = tensioned_lug_spacing - 2.5;
  
  for (a = [-1, 1], b = [-1, 1]) {
    scale([a, b, 1]) {
      difference() {
        intersection() {
          translate([width/2-side_plate_width, -side_plate_length/2, -3*lug_radius])
            chamfered_cube([
              side_plate_width,
              side_plate_length/2+10,
              3*lug_radius+mag_plate_thickness+loose_clearance
            ], 1);
          
          // More aggressive inner chamfer ("flared magwell").
          translate([width/2, 500, 15.5])
            scale([1, 1, 3])
              rotate([90, 0, 0])
                cylinder(1000, 8, 8);
        }
      
        // Lug cutout.
        translate([-500, -tensioned_lug_spacing/2, -lug_radius])
          rotate([0, 90, 0])
            cylinder(1000, lug_radius, lug_radius);
      }
      
      // Tuck-under lug. Make it slightly smaller so that it isn't another bearing surface.
      tuck_under_radius = lug_radius - 0.3;
      translate([width/2-side_plate_width, -tensioned_lug_spacing/2, -lug_radius]) {
        rotate([30, 0, 0]) {
          translate([0, 0, -lug_radius-tuck_under_radius]) {
            rotate([0, 90, 0]) {
              translate([0, 0, 1])
                linear_extrude(1, scale=tuck_under_radius/(tuck_under_radius-1))
                  circle(tuck_under_radius-1);
              translate([0, 0, 2])
                linear_extrude(side_plate_width-3)
                  circle(tuck_under_radius);
              translate([0, 0, side_plate_width-1])
                linear_extrude(1, scale=(tuck_under_radius-1)/tuck_under_radius)
                  circle(tuck_under_radius);
            }
          }
        } 
      }
    }
  }
}

module grip() {
  height = 94;
  
  translate([0, 13, 1-height]) {
    morph(dupfirst([
      // Bottom, chamfered in slightly.
      [0,   13, 12,   0],
      [1,   14, 13,   0],
      // Swell out in back.
      [18,  14, 13,   0],
      [33,  16, 13,   0],
      [53,  16, 13,   0],
      [63,  14, 12,   0],
      // Pinch in front for thumb and finger.
      [79,  13, 11,   0],
      [84,  13, 11,   1],
      [88,  13, 11,   3],
      // Beavertail.
      [90,  13, 11.3, 6],
      [92,  13, 11.6, 10],
      [93,  12, 12,   14],
      [94,  11, 11,   14],
    ])) {
      hull() {
        z = $m[0];
        forward =
          // No tilt up to 8mm. Slight tilt from there to 13mm.
          max(0, z-8)*0.2 +
          // Full 18 degree tilt after 13mm.
          max(0, z-13)*0.133333 -
          // No tilt for top 1mm, which joins to receiver
          max(0, z-93)*0.333333;

        translate([0, forward, 0]) {
          translate([0, 14, 0]) circle($m[2]);
          translate([0, -14-$m[3], 0]) circle($m[1]);
        }
      }
    }
  }
}

// TODO: better naming between this and 'trigger'
module trigger2() {
  height = 28;
  length = 40;
  
  translate([0, 0, 1-height]) {
    morph(dupfirst([
      [0],
      [height],
    ])) {
      difference() {
        z = $m[0];

        // Chamfer the sharp edges on the bottom.
        chamfer = 0.6;
        offset(z < chamfer ? z-chamfer : 0) {
          hull() {        
            translate([
              0,
              height * circ(z/height - 0.5),
              0
            ])
              circle(action_width/2);
            
            translate([-action_width/2, -length, 0])
              square(action_width);
          }
        }
      }
    }
  }
}

module preview() {
  color("yellow") { receiver(); grip(); }
  color("red") translate([0, receiver_length+loose_clearance, plate_thickness+loose_clearance]) release();
  color("blue") translate([0, receiver_length-plate_length, 0]) plate();
  color("orange") translate([0, receiver_back_offset+6, 0]) scale([1, -1, 1]) trigger();
  color("gray") translate([0, outer_lug_spacing/2-lug_radius-0.1, receiver_height]) mag();
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
  
  translate([50, -50, mag_height+loose_clearance])
    scale([1, 1, -1]) mag();
}

preview();