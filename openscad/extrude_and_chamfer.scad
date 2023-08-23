// Like linear_extrude, but chamfers the bottom and/or top. Chamfering
// the bottom can counter elephant's foot.
module extrude_and_chamfer(height, bottom_chamfer=0, top_chamfer=0) {
  // Chamfered bottom.
  hull() {
    linear_extrude(0.0001)
      offset(delta=-bottom_chamfer)
        children();
    translate([0, 0, abs(bottom_chamfer)])
      linear_extrude(0.0001)
        children();
  }
  
  // Main body.
  hull() {
    translate([0, 0, abs(bottom_chamfer)])
      linear_extrude(0.0001)
        children();
    translate([0, 0, height-abs(top_chamfer)])
      linear_extrude(0.0001)
        children();
  }
  
  // Chamfered top.
  hull() {
    translate([0, 0, height-abs(top_chamfer)])
      linear_extrude(0.0001)
        children();
    translate([0, 0, height])
      linear_extrude(0.0001)
        offset(delta=-top_chamfer)
          children();
  }
}
