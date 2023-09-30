include <barrel.scad>
include <common.scad>

follower_finger_width = 10;
follower_front_wall = 2.5;
follower_width = barrel_width + follower_finger_width*2 + 2;

module follower() {
  finger_thickness = barrel_gap;
  tunnel_id = string_diameter + 1;
  
  // Enough chamfer to absort the elephant foot and then some, for smooth movement.
  chamfer = 0.7;
  
  difference() {
    union() {
      // Front piece which passes through the slots.
      outer_radius = follower_front_wall + tunnel_id*0.3;
      hull() {
        for (a = [-1, 1]) {
          scale([1, a, 1]) {
            difference() {
              translate([eps, follower_width/2 - outer_radius, -finger_thickness/2])
                rotate_extrude(angle = 90)
                  square([outer_radius, finger_thickness]);
              
              // Chamfer leading and trailing edges.
              for (b = [-1, 1])
                scale([1, 1, b])
                  for (x = [0, outer_radius])
                    translate([x, 0, finger_thickness/2])
                      cube([chamfer*2, follower_width+2*eps, chamfer*2], center=true);
            }
          }
        }
      }
      
      // Piston shape which engages with the bottom bore, to keep the follower
      // straight. We have to instantiate it twice with different radii to prevent
      // elephant's foot.
      piston_length = tunnel_id + follower_front_wall + 2.5;
      $fa = 5;
      intersection() {
        rotate([0, 90, 0])
          flare_cylinder(piston_length, (main_bore-extra_loose)/2, chamfer, chamfer);
        translate([0, -main_bore/2, finger_thickness/2-main_bore-0.2])
          cube([piston_length+2*eps, main_bore, main_bore]);
      }
      intersection() {
        rotate([0, 90, 0])
          flare_cylinder(piston_length, (main_bore-extra_loose)/2-0.3, chamfer, chamfer);
        translate([0, -main_bore/2, finger_thickness/2-main_bore])
          cube([piston_length+2*eps, main_bore, main_bore]);
      }
    }
    
    // String tunnel.
    translate([tunnel_id/2 + follower_front_wall, 0, 0]) {
      for (a = [-1, 1]) {
        scale([1, a, 1]) {
          translate([0, eps, 0])
            rotate([90, 0, 0])
              linear_extrude(follower_width/2 - follower_front_wall + 2*eps)
                octagon(tunnel_id);
          
          translate([-follower_front_wall - tunnel_id/2, -follower_width/2 + follower_front_wall, 0])
            rotate([0, 0, -90])
              rotate_extrude(angle = 90)
                translate([follower_front_wall + tunnel_id/2, 0, 0])
                  octagon(tunnel_id);
        }
      }
    }
  }
}

follower();