include <barrel.scad>
include <common.scad>

bolt_diameter = main_bore - extra_loose;
bolt_length = 70;
bolt_chamfer = 0.7;

// This need not extend very far into the slots. Just enough to keep the bolt from
// rotating.
rail_width = barrel_width - 4.5;
rail_height = barrel_gap - extra_loose;

tunnel_id = string_diameter + 1;

module bolt_exterior() {
  $fa = 5;
  
  intersection() {
    flare_cylinder(bolt_length, bolt_diameter/2, bolt_chamfer, bolt_chamfer);
    
    // Cut off the top of the bolt to make sure it doesn't catch the next
    // dart when it slides past at high speed.
    translate([0, 1.5, bolt_length/2])
      cube([bolt_diameter, bolt_diameter, bolt_length], center=true);
  }

  hull() {
    cube([rail_width - 2*bolt_chamfer, rail_height - 2*bolt_chamfer, eps], center=true);
    translate([0, 0, bolt_chamfer])
      cube([rail_width, rail_height, eps], center=true);
    translate([0, 0, bolt_length-bolt_chamfer])
      cube([rail_width, rail_height, eps], center=true);
    translate([0, 0, bolt_length])
      cube([rail_width - 2*bolt_chamfer, rail_height - 2*bolt_chamfer, eps], center=true);
  }
}

module bolt() {
  difference() {
    bolt_exterior();
    
    translate([-rail_width/2-eps, 0, tunnel_id/2 + 2.5])
      rotate([0, 90, 0])
        linear_extrude(rail_width+2*eps)
          octagon(tunnel_id);
  }
}

bolt();