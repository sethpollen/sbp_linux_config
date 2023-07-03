$fa = 5;
$fs = 0.5;
eps = 0.000001;

module reify(translation) {
  translate(translation)
    linear_extrude(eps)
      children();
}

module chain(z_steps) {
  if ($children > 0) {
    for (i = [0 : $children-2]) {
      hull() {
         children(i);
         children(i+1);
      }
    }
  }
}

module round_rect(x, y1, y2, radius) {
  assert(x >= radius*2);
  assert(y1 >= radius*2);
  assert(y2 >= radius*2);
  
  hull()
    for (a = [-1, 1], b = [-1, 1])
      translate([
        (x*0.5-radius)*a,
        ((a == 1 ? y1 : y2)*0.5-radius)*b,
        0
      ])
        circle(radius);
}

// The forward receiver should sit right on the x-y plane when added.
module grip() {
  height = 75;
  angle = 18;
  disp = height*tan(angle);
  chain() {
    reify([disp-4, 0, 8])               round_rect(63, 23, 23, 6);
    reify([disp-4, 0, 6])               round_rect(63, 23, 23, 6);
    reify([disp-1, 0, 3])               round_rect(57, 23, 23, 6);
    reify([disp, 0, 0])                 round_rect(55, 28, 28, 13);
    reify([0.9*disp+1, 0, -0.1*height]) round_rect(53, 24, 28, 12);
    reify([0.7*disp, 0, -0.3*height])   round_rect(55, 28, 32, 14);
    reify([0.4*disp, 0, -0.6*height])   round_rect(55, 28, 32, 14);
    reify([0.2*disp, 0, -0.8*height])   round_rect(55, 28, 28, 13);
    reify([1, 0, -height])              round_rect(55, 28, 28, 13);
    reify([0, 0, -height-8])            round_rect(55, 28, 28, 13);
    reify([0, 0, -height-15])           round_rect(55, 28, 28, 14);
    reify([0, 0, -height-16])           round_rect(53, 26, 26, 13);
  }
}

grip();
