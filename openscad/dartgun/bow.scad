include <common.scad>

tube_wall = 2.5;
tube_id = spring_od + loose;

roller_cavity_diameter = roller_diameter + loose;
string_cavity_diameter = string_diameter + 2;

tube_gap = string_cavity_diameter + 3;
roller_length = 2*tube_id + tube_gap + 5;
roller_cavity_length = roller_length + 1;

tube_exterior_length = tube_id + 2*tube_wall;
tube_exterior_width = roller_cavity_length + 2*tube_wall;

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
          circle(d=tube_exterior_length);
    
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
          translate([-roller_cavity_diameter/2, -roller_cavity_length/2, base_thickness+spring_min_length-eps])
            cube([roller_cavity_diameter, roller_cavity_length, height+2*eps]);
                    
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
                  polygon([[0, 0], [4, 0], [0, 6]]);
      }
      
      // Spring cavities.
      for (a = [-1, 1])
        translate([0, a*(tube_id+tube_gap)/2, base_thickness-eps])
          linear_extrude(height+2*eps)
            circle(d=tube_id);
    }
    
    // Connecting block directly underneath the roller. The roller will rest on this
    // when fully charged.
    translate([-(roller_diameter-1)/2, -string_cavity_diameter/2, 0])
      cube([roller_diameter-1, string_cavity_diameter, base_thickness+spring_min_length]);
    
    // Base plate.
    translate([0, -string_cavity_diameter/2, 0])
      cube([tube_exterior_length/2, string_cavity_diameter, base_thickness]);
    
    // Hitching post for one end of the string.
    post_diameter = 4;
    translate([tube_exterior_length/2-post_diameter/2, tube_gap/2, post_diameter/2+string_diameter+base_thickness])
      rotate([90, 0, 0])
        linear_extrude(tube_gap) octagon(post_diameter);
  }
}

limb();
