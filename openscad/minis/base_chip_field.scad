use <base.scad>

translate([-75, -75, 0])
  repeatx(4, 50)
    repeaty(4, 50)
      base_chip();