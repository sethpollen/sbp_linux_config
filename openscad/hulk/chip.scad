layer = 0.2;
eps = 0.001;

// Child is the 2d shape.
module blank_chip(height, chamfer=1) {
  // Bottom 2 layers: Extra chamfer for elephant foot.
  linear_extrude(layer)
    offset(-chamfer - 0.5*layer)
      children();
  translate([0, 0, layer])
    linear_extrude(layer)
      offset(-chamfer + 1.5*layer)
        children();

  for (z = [2*layer : layer : chamfer - layer])
    translate([0, 0, z])
      linear_extrude(layer)
        offset(-chamfer + layer + z)
          children();

  translate([0, 0, chamfer])
    linear_extrude(height - 2*chamfer)
      children();

  for (z = [0 : layer : chamfer - layer])
    translate([0, 0, height - chamfer + z])
      linear_extrude(layer)
        offset(-z)
          children();
}

module blip(count) {
  difference() {
    blank_chip(7, 1.6)
      circle(d=21, $fn=80);
    
    translate([0, 0, -eps]) {
      for (a = (count == 1) ? [0] : (count == 2) ? [-0.5, 0.5] : [-1, 0, 1]) {
        translate([0, 3.4*a]) {
          linear_extrude(5, scale=0.3) {
            square([8, 2.1], center=true);
          }
        }
      }
    } 
  }
}

// TODO: genestealer entry, jam, breach, ladders, flamer, power field, space marine controlled area,
// doors, force barrier, psi counter, assault cannon counter, command point counter