include <common.scad>
use <../grip.scad>

tube_wall = 2.5;
tube_id = spring_od + 0.7;

roller_cavity_diameter = roller_diameter + loose;
string_cavity_diameter = string_diameter + 2;

// Gap between the inner edges of the two tubes.
tube_gap = string_cavity_diameter + 3;
roller_length = 2*tube_id + tube_gap + 5;
roller_cavity_length = roller_length + 1;

tube_exterior_length = tube_id + 2*tube_wall;
tube_exterior_width = roller_cavity_length + 2*tube_wall;

socket_depth = 5;

// Bases of tubes.
base_thickness = 2.5;

// Allow the roller to fit flush into the cavities.
tube_height = spring_max_length + roller_diameter + base_thickness;

brace_length = tube_height * 0.6;
brace_offset = tube_gap * 0.6;
brace_width = 8;

// Nerf darts are 0.50 cal.
dart_diameter = 12.7;
dart_length = 72;

module tube_exterior_2d() {
  intersection() {
    hull()
      for (a = [-1, 1])
        translate([0, a*(tube_exterior_width-tube_exterior_length)/2, 0])
          circle(d=tube_exterior_length);
    
    // Bevel for the incoming string.
    factor = 2;
    for (a = [-1, 1])
      translate([0, a * (tube_exterior_length*factor/2 + tube_gap/4), 0])
        circle(d=tube_exterior_length*factor);
  }
}

module limb() {  
  translate([-tube_exterior_length/2, 0, 0]) {
    difference() {
      union() {
        difference() {
          // Exterior.
          linear_extrude(tube_height)
            tube_exterior_2d();
          
          // Roller cavity.
          translate([-roller_cavity_diameter/2, -roller_cavity_length/2, base_thickness+spring_min_length-eps])
            cube([roller_cavity_diameter, roller_cavity_length, tube_height+2*eps]);
                    
          // String cavity.
          translate([-tube_exterior_length/2-1, -string_cavity_diameter/2, -eps])
            cube([tube_exterior_length+2, string_cavity_diameter, tube_height+2*eps]);
        }
        
        // Connect the tops of the tubes on both sides, for strength.
        for (a = [-1, 1])
          scale([a, 1, 1])
            translate([tube_exterior_length/2, tube_gap, tube_height])
              rotate([90, 180, 0])
                linear_extrude(tube_gap*2)
                  polygon([[0, 0], [4, 0], [0, 4]]);
      }
      
      // Spring cavities.
      for (a = [-1, 1])
        translate([0, a*(tube_id+tube_gap)/2, base_thickness-eps])
          linear_extrude(tube_height+2*eps)
            circle(d=tube_id);
    }
    
    // Connecting block directly underneath the roller. The roller will rest on this
    // when fully charged.
    translate([-(roller_diameter-1)/2, -string_cavity_diameter/2, 0])
      cube([roller_diameter-1, string_cavity_diameter, base_thickness+spring_min_length]);
        
    // Base plates for braces.
    for (a = [-1, 1]) {
      scale([1, a, 1]) {
        translate([0, brace_offset, 0]) {
          hull() {
            translate([tube_wall-brace_length-tube_exterior_length/2, 0, 0])
              cube([brace_length, brace_width, base_thickness]);
            translate([tube_wall-tube_exterior_length/2, 0, tube_height*0.7-base_thickness])
              cube([eps, tube_id*0.2, base_thickness]);
          }
        }
      }
    }
  }
}

module socket() {
  translate([-1.5, -1.5, -eps])
    flare_cube([3, 3, socket_depth], -foot);
}

module lug() {
  flare_cube([3-snug, 3-snug, 2*socket_depth-2], foot);
}

module limb_sockets() {
  translate([-tube_exterior_length/2, 0, 0])
    socket();
  for (a = [-1, 1])
    scale([1, a, 1])
      translate([-brace_length-tube_exterior_length/2, brace_offset+brace_width/2, 0])
        socket();
}

module socketed_limb() {
  difference() {
    limb();
    limb_sockets();
  }
}

barrel_length = 200;
barrel_wall = 2;
barrel_width = dart_diameter + 2*barrel_wall;
bore_diameter = dart_diameter + loose;

block_front_offset = 20;

// Blocks to connect barrel and limbs.
block_width = 15;
block_height = 2*brace_width + 2*brace_offset;
block_length = tube_exterior_length + brace_length - tube_wall + block_front_offset;

module barrel() {
  front_offset = tube_wall + tube_id/2 + (roller_diameter-1)/2;
  
  // Main barrel.
  difference() {
    union() {
      translate([0, -barrel_width/2, -block_height/2])
        cube([barrel_length, barrel_width, block_height]);
      
      // Side blocks for attaching limbs.
      for (a = [-1, 1])
        scale([1, a, 1])
          translate([-block_front_offset, barrel_width/2, -block_height/2])
            cube([block_length, block_width, block_height]);
    }
    
    // Slot for string.
    translate([250 + front_offset, 0, 0])
      cube([500, 500, string_cavity_diameter], center=true);
    
    // Cut away the top of the barrel behind the blocks, for easy access.
    translate([block_length-block_front_offset+250, 0, 10-eps])
      cube([500, 500, 20], center=true);
    
    // Bore.
    translate([-eps, 0, 0])
      rotate([0, 90, 0])
        cylinder(barrel_length+2*eps, d=bore_diameter);

    // Chamfer edges exposed to the string.
    factor = 1.1;
    for (a = [-1, 1]) {
      scale([1, a, 1]) {
        translate([block_length/2 + front_offset, block_width + barrel_width/2, 0])
          rotate([45, 0, 0])
            cube([block_length, string_cavity_diameter*factor, string_cavity_diameter*factor], center=true);
        
        difference() {
          translate([block_length-block_front_offset, 0, 0])
            rotate([45, 0, 90])
              cube([block_width*2+barrel_width, string_cavity_diameter*factor, string_cavity_diameter*factor], center=true);
          // Don't leave a notch in the bottom part of the barrel.
          translate([0, 0, -5])
            cube([200, 200, 10], center=true);
        }
      }
    }
    
    // String attachment points in front.
    for (a = [-1, 1]) {
      scale([1, a, 1]) {
        translate([-block_front_offset*0.8-block_width, 0, 0]) {
          rotate([0, 90, 50]) {
            cylinder(100, d=string_diameter+loose);
            cylinder(20, d=2*string_diameter+loose);
          }
        }
      }
    }

    // Attachment sockets for the limbs.
    for (a = [-1, 1])
      scale([1, a, 1])
        translate([0, barrel_width/2+block_width, 0])
          scale([1, -1, 1])
            rotate([90, 0, 180])
              limb_sockets();
  }
    
  // Attach a grip.
  translate([110, 0, -block_height/2])
    rotate([0, 0, 90])
      grip();
}

//barrel();
//for (a = [-1, 1]) scale([1, a, 1]) translate([0, barrel_width/2+block_width, 0]) rotate([90, 0, 180]) limb();
//socketed_limb();
for (a = [1:6]) translate([a*5, 0, 0]) lug();
