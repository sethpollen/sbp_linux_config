// TODO: needs work

module serpent(segments, pos=0) {
  if (pos < len(segments)) {
    radius = segments[pos][0];
    angle = segments[pos][1];
    heading = segments[pos][2];
    
    echo(pos);
    if (pos>0)
    rotate([0, heading])
      translate([-radius, 0])
        rotate_extrude(angle=angle)
          translate([radius, 0])
            rotate([0, 0, heading])
              children();
    
    serpent(segments, pos+1);
  }
}

serpent([
  [10, 180, 45],
  [20, 180, 135],
]) {
  square(5, center=true);
}