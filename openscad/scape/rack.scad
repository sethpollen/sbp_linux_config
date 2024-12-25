eps = 0.00001;
$fn = 50;

hole_diam = 33.5;

flange = 3.5;

hole_depth = 3.2;
floor_height = 1;
height = floor_height + hole_depth; 

module gridify(wall, rows, cols, gap, extra_gap) {
  for (r = [1:rows], c = [1:cols])
    translate([(c-1) * (hole_diam + gap), (r-1) * (hole_diam + gap + extra_gap)])
      children();
}

module floor(wall, rows, cols, gap, extra_gap) {
  difference() {
    gridify(wall, rows, cols, gap, extra_gap)
      offset(wall)
        circle(d=hole_diam);
    gridify(wall, rows, cols, gap, extra_gap)
      offset(-flange)
        circle(d=hole_diam);
  }
}

module wall(wall, rows, cols, gap, extra_gap) {
  difference() {
    gridify(wall, rows, cols, gap, extra_gap)
      offset(wall)
        circle(d=hole_diam);
    gridify(wall, rows, cols, gap, extra_gap)
      circle(d=hole_diam);
  }
}

module main(wall, rows, cols, gap, extra_gap) {
  difference() {
    union() {
      linear_extrude(0.2)
        offset(-0.3)
          floor(wall, rows, cols, gap, extra_gap);
      
      translate([0, 0, 0.2])
        linear_extrude(floor_height - 0.2)
          floor(wall, rows, cols, gap, extra_gap);
    
      translate([0, 0, floor_height])
        linear_extrude(hole_depth)
          wall(wall, rows, cols, gap, extra_gap);
    }
    gridify(wall, rows, cols, gap, extra_gap) {
      translate([0, 0, 0.6])
        cylinder(h=floor_height, d1=hole_diam-flange*2, d2=hole_diam-flange*2+2.5);
      translate([0, 0, height - 0.8])
        cylinder(h=1.01, d1=hole_diam, d2=hole_diam+2);
    }
  }
}

module basic_single_tray() {
  main(5.6, 3, 3, 5, 4.2);
}

module kyrie_tray() {
  // Internal dimensions at the bottom of the tub:
  //   345.2 mm: accommodates 8 cells (half: 172.6 mm)
  //   221.8 mm: accomodates 5 cells
  main(5.9, 5, 4, 8.86, 1.71);  // 172.4 x 221.5
}

difference() {
  kyrie_tray();
  translate([0, 0, 5001])
    cube(10000, center=true);
  translate([63, 88, 0])
    cube([130, 187, 100], center=true);
}