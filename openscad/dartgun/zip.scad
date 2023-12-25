zip_channel_height = 3.2;
zip_channel_width = 6.5;

module zip_channel(inner_dims) {
  linear_extrude(zip_channel_width) {
    difference() {
      offset(6 + zip_channel_height)
        square(inner_dims - [7, 7], center=true);
      offset(6)
        square(inner_dims - [7, 7], center=true);
    }
  }
}
