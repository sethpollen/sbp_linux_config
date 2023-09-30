include <barrel.scad>
include <common.scad>

// Enough chamfer to absorb the elephant foot and then some, for smooth movement.
wing_chamfer = 0.7;

wing_thickness = barrel_gap;
wing_width = 40;
follower_front_wall = 2.5;

follower_tunnel_id = string_diameter + 1;

// Front piece which passes through the slots.
module follower_wings() {
  length = 9.2;

  translate([0, -wing_width/2, -wing_thickness/2])
    chamfered_cube([length, wing_width, wing_thickness], wing_chamfer);
}

// Piston shape which engages with the bottom bore, to keep the follower
// straight. We have to instantiate it twice with different radii to prevent
// elephant's foot.
module follower_piston() {
  length = 11;

  $fa = 5;
  intersection() {
    rotate([0, 90, 0])
      flare_cylinder(length, (main_bore-extra_loose)/2, wing_chamfer, wing_chamfer);
    translate([0, -main_bore/2, wing_thickness/2-main_bore-0.2])
      cube([length+2*eps, main_bore, main_bore]);
  }
  intersection() {
    rotate([0, 90, 0])
      flare_cylinder(length, (main_bore-extra_loose)/2-0.3, wing_chamfer, wing_chamfer);
    translate([0, -main_bore/2, wing_thickness/2-main_bore])
      cube([length+2*eps, main_bore, main_bore]);
  }
}

module follower() {  
  difference() {
    union() {
      follower_wings();      
      follower_piston();
    }
    
    // String tunnel.
    translate([follower_tunnel_id/2 + follower_front_wall, 0, 0]) {
      for (a = [-1, 1]) {
        scale([1, a, 1]) {
          translate([0, eps, 0])
            rotate([90, 0, 0])
              linear_extrude(wing_width)
                octagon(follower_tunnel_id);
          
          translate([-follower_front_wall - follower_tunnel_id/2, -wing_width/2 + follower_front_wall, 0])
            rotate([0, 0, -90])
              rotate_extrude(angle = 90)
                translate([follower_front_wall + follower_tunnel_id/2, 0, 0])
                  octagon(follower_tunnel_id);
        }
      }
    }
  }
}

follower();