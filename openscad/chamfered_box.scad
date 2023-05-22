// 'd' is the outer dimensions of the box. 'chamfer' is the
// amount to cut away from each edge and corner.
module chamfered_box(d, chamfer) {
  assert(d.x >= chamfer*2);
  assert(d.y >= chamfer*2);
  assert(d.z >= chamfer*2);

  minkowski() {
    cube(d - [chamfer*2, chamfer*2, chamfer*2], center=true);
    for (a = [-1, 1])
      scale([1, 1, a])
        linear_extrude(chamfer, scale = 0)
          rotate([0, 0, 45])
            square(norm([chamfer, chamfer]), center = true);
  }
}

chamfered_box([18, 18, 3.5], 0.5);