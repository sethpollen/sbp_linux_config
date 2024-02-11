// For some reason the .stl has 2 bugs and 2 bases. I want to print them
// with different settings. The code bellow splits out just 1 bug, with
// no base.
intersection() {
  import("fixed/bug.stl");
  
  // We also cut off the very tips of the claws; they don't print well.
  translate([68, 0, -42.7])
    cube(100, center=true);
}
