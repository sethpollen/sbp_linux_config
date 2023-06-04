use <head.scad>
use <engrave.scad>

// First child is the chip. Remaining children are
// the 2-D engravings.
module engrave_chip() {
  difference() {
    children(0);
    translate([0, 0, 3.5])
      engrave()
        children([1:$children-1]);
  }
}

module magic_sword() {
  engrave_chip() {
    heavy_weapon();
    sword_2();
    magic_circle_2();
  }
}

module iron_sword() {
  engrave_chip() {
    light_weapon();
    sword_2();
  }
}

module magic_helm() {
  engrave_chip() {
    heavy_armor();
    magic_helm_2();
  }
}

module iron_helm() {
  engrave_chip() {
    light_armor();
    iron_helm_2();
  }
}

module iron_mail() {
  engrave_chip() {
    light_armor();
    square_mail_2();
  }
}

module wall() {
  engrave_chip() {
    heavy_armor();
    bricks_2();
  }
}

// Printable.
translate([0, 0, 0]) magic_sword();
translate([0, 25, 0]) iron_sword();
translate([25, 0, 0]) magic_helm();
translate([25, 25, 0]) iron_helm();
translate([-25, 0, 0]) iron_mail();
translate([-25, 25, 0]) wall();