$fa = 5;
$fs = 0.5;
eps = 0.001;

tube_id = 11;
tube_od = tube_id + 4;
tube_length = 50;

loom_width = 20.9;
loom_gap = 5;
loom_wall = 2.2;
lip = 1.4;
loom_height = 13;

join = 5;

difference() {
  union() {
    translate([0, 0, -tube_length])
      cylinder(tube_length + join, d=tube_od);
    
    translate([0, 0, loom_height/2 - eps])
      cube([loom_width + 2*lip, loom_gap + 2*loom_wall, loom_height], center=true);
  }
  
  // Inside of tube.
  translate([0, 0, -tube_length-eps])
    cylinder(tube_length*2, d=tube_id);
  
  // Transverse gap.
  translate([0, 0, loom_height/2 + join - eps])
    cube([loom_width + 2*lip + eps, loom_gap, loom_height + eps], center=true);
  
  // Cross gap.
  translate([0, 0, loom_height/2 + join - eps])
    cube([tube_id*0.88, 20, loom_height + eps], center=true);
  
  // Lips.
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([loom_width/2, -10, lip])
        cube([20, 20, loom_height - 2*lip]);
  
  // Observation port on one side.
  translate([-10, loom_gap/2 + loom_wall + eps, -join])
    cube(20);
  translate([-tube_id*0.44, loom_gap/2 + eps, -join])
    cube([tube_id*0.88, 20, 20]);
  
  // Gap between lips for hook.
  for (a = [-1, 1])
    scale([a, 1, 1])
      translate([tube_od*0.45, -loom_gap/2, -3-2*eps])
        cube([20, loom_gap, 20]); 
  
  // Inner chamfer on bottom.
  translate([0, 0, -tube_length-eps])
    linear_extrude(0.7, scale=(tube_id-0.7)/tube_id)
      circle(d=tube_id+0.7);
}

