include <common.scad>

tube_wall = 3;
tube_id = spring_od + loose;

rod_cavity_diameter = rod_diameter + loose;
string_cavity_diameter = string_diameter + 2;

tube_gap = string_cavity_diameter + 2;

rod_cavity_end = 3;
rod_cavity_length = 2*tube_id + 2*rod_cavity_end + tube_gap;

// Allow plenty of clearance for the rod ends. I won't be able to saw it
// off precisely anyway.
rod_length = rod_cavity_length - 1.5;
echo(str("ROD LENGTH: ", rod_length, " mm"));

tube_exterior_length = tube_id + 2*tube_wall;
tube_exterior_width = rod_cavity_length + 2*tube_wall;

module tube_exterior_2d() {
  intersection() {
    hull()
      for (a = [-1, 1])
        translate([0, a*(tube_exterior_width-tube_exterior_length)/2, 0])
          octagon(tube_exterior_length);
    
    // Bevel for the incoming string.
    union() {
      factor = 1.5;
      for (a = [-1, 1])
        translate([0, a * (tube_exterior_length*factor/2 + tube_gap/4), 0])
          circle(d=tube_exterior_length*factor);
      
      // Cancel the bevel on one side, where the string is anchored.
      translate([tube_exterior_length/2, 0, 0])
        square([tube_exterior_length, tube_exterior_width], center=true);
    }
  }
}

module tubes() {
  base_thickness = 2.5;
  // Allow the rod to fit flush into the cavities.
  height = spring_max_length + rod_diameter + base_thickness;
  
  difference() {
    union() {
      difference() {
        // Exterior.
        linear_extrude(height)
          tube_exterior_2d();
        
        // Rod cavity.
        translate([-rod_cavity_diameter/2, -rod_cavity_length/2, base_thickness+spring_min_length-eps])
          cube([rod_cavity_diameter, rod_cavity_length, height+2*eps]);
        
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
          circle_ish(tube_id/2);
  }
  
  // Connecting block directly underneath the rod. The rod will rest on this
  // when fully charged.
  translate([-(rod_diameter-1)/2, -string_cavity_diameter/2, 0])
    cube([rod_diameter-1, string_cavity_diameter, base_thickness+spring_min_length]);
  
  // Hitching post for one end of the string.
  post_diameter = 3;
  translate([(rod_cavity_diameter+post_diameter)/2+string_diameter, tube_gap, post_diameter/2+string_diameter+1])
    rotate([90, 0, 0])
      linear_extrude(tube_gap*2)
        octagon(post_diameter);
}

tubes();
