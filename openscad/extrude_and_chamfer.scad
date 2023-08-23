// Like linear_extrude, but chamfers the bottom to counter elephant's
// foot.
module extrude_and_chamfer(height, bottom_chamfer) {
  hull() {
    // Chamfered bottom.
    linear_extrude(0.0001)
      offset(delta=-bottom_chamfer)
        children();
    
    // Main body.
    translate([0, 0, bottom_chamfer])
      linear_extrude(0.0001)
        children();
    translate([0, 0, height])
      linear_extrude(0.0001)
        children();
  }
}
