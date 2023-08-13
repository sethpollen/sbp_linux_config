include <common.scad>

tube_wall = 2.5;
tube_id = spring_od + loose;

roller_cavity_diameter = roller_diameter + loose;
string_cavity_diameter = string_diameter + 2;

tube_gap = string_cavity_diameter + 3;

tube_exterior_length = tube_id + 2*tube_wall;
tube_exterior_width = 2*tube_id + tube_gap + 2*tube_wall;

barrel_wall = 2.5;
barrel_length = 220;

// Enough room for a Nerf dart.
barrel_id = 15;
barrel_od = barrel_id + 2*barrel_wall;

// Bases of tubes and barrel.
base_thickness = 2.5;

module tube_exterior_2d() {
  intersection() {
    hull()
      for (a = [-1, 1])
        translate([0, a*(tube_exterior_width-tube_exterior_length)/2, 0])
          octagon(tube_exterior_length);
    
    // Bevel for the incoming string.
    union() {
      factor = 1.8;
      for (a = [-1, 1])
        translate([0, a * (tube_exterior_length*factor/2 + tube_gap/4), 0])
          circle(d=tube_exterior_length*factor);
      
      // Cancel the bevel on one side, where the string is anchored.
      translate([tube_exterior_length/2, 0, 0])
        square([tube_exterior_length, tube_exterior_width], center=true);
    }
  }
}

module limb() {
  // Allow the roller to fit flush into the cavities.
  height = spring_max_length + roller_diameter + base_thickness;
  
  translate([-tube_exterior_length/2, 0, 0]) {
    difference() {
      union() {
        difference() {
          // Exterior.
          linear_extrude(height)
            tube_exterior_2d();
          
          // Roller cavity.
          roller_cavity_length = tube_gap + 2*tube_wall + 2*eps;
          translate([-roller_cavity_diameter/2, -roller_cavity_length/2, base_thickness+spring_min_length-eps])
            cube([roller_cavity_diameter, roller_cavity_length, height+2*eps]);
          
          // Cut an extra wide gap against the build plate, so supports can be placed
          // for the roller bearing surface above.
          translate([0, -tube_gap/2, base_thickness + spring_min_length + roller_diameter*0.7 - eps])
            cube([tube_id, tube_gap, height+2*eps]);
          
          // String cavity.
          translate([-tube_exterior_length/2-1, -string_cavity_diameter/2, -eps])
            cube([tube_exterior_length+2, string_cavity_diameter, height+2*eps]);
        }
        
        // Connect the tops of the tubes on both sides, for strength.
        for (a = [-1, 1])
          scale([a, 1, 1])
            translate([tube_exterior_length/2, tube_gap, height])
              rotate([90, 180, 0])
                linear_extrude(tube_gap*2)
                  polygon([[0, 0], [5, 0], [0, 5]]);
      }
      
      // Spring cavities.
      for (a = [-1, 1])
        translate([0, a*(tube_id+tube_gap)/2, base_thickness-eps])
          linear_extrude(height+2*eps)
            octagon(tube_id);
    }
    
    // Connecting block directly underneath the roller. The roller will rest on this
    // when fully charged.
    translate([-(roller_diameter-1)/2, -string_cavity_diameter/2, 0])
      cube([roller_diameter-1, string_cavity_diameter, base_thickness+spring_min_length]);
    
    // Hitching post for one end of the string.
    post_diameter = 4;
    translate([tube_exterior_length/2-post_diameter/2, tube_gap/2, post_diameter/2+string_diameter+1])
      rotate([90, 0, 0])
        linear_extrude(tube_gap) octagon(post_diameter);
  }
}

module barrel() {
  linear_extrude(barrel_length) {
    difference() {
      square(barrel_od, center=true);
      octagon(barrel_id);
      
      // String slots along sides.
      square([barrel_od+2*eps, string_cavity_diameter], center=true);
    }
  }
  
  // Back ring.
  translate([0, 0, barrel_length]) {
    linear_extrude(base_thickness) {
      difference() {
        square(barrel_od, center=true);
        octagon(barrel_id); 
      }
    }
  }
}

module bow() {
  // Limbs.
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([barrel_id/2, 0, 0])
        rotate([0, 90, 0])
          limb();
  
  barrel();
  
  // Reinforce the joint between barrel and limbs.
  reinforcement_thickness = 5;
  for (a = [-1, 1]) {
    scale([1, a, 1]) {
      hull() {
        translate([-spring_max_length, barrel_id/2, tube_exterior_length])
          cube([spring_max_length*2, reinforcement_thickness, eps]);
        translate([0, barrel_id/2, tube_exterior_length+spring_max_length])
          cube([eps, barrel_wall, eps]);
      }
    }
  }
  
  // A crude handle.
  handle_length = 80;
  translate([0, -barrel_od/2, 10])
    rotate([90, 0, 0])
      linear_extrude(handle_length-barrel_od/2)
        octagon(20);
  
  // Print aids for handle end.
  translate([-5, -handle_length-5.2, 0])
    cube([10, 5, 0.2]);
  translate([-5, -handle_length-5.2, 0])
    cube([10, 0.6, 1.5]);
  
  // Print aids for limb ends.
  for (a = [-1, 1]) {
    scale([a, 1, 1]) {
      translate([barrel_id/2 + spring_max_length + roller_diameter + base_thickness + 0.2, -20, 0])
        cube([3, 40, 0.2]);
      translate([barrel_id/2 + spring_max_length + roller_diameter + base_thickness + 2, -3, 0])
        cube([0.6, 6, 1.5]);
    }
  }
}

// TODO: need to print little followers to go between spring and roller.

rotate([0, 90, 0]) limb();