// Utilities for composing smooth solids from a list of cross-sections.

// Searches over a list of key/value pairs (sorted by key), returning
// the index of the pair with the largest key less than or equal to 'target'.
function binsearch(target, pairs) = binsearch_impl(target, pairs, 0, len(pairs));
function binsearch_impl(target, pairs, lo, hi) = (
  // Base case.
  hi == lo + 1 ? lo :
  // Recursive case.
  let (mid = floor((hi + lo) / 2))
  pairs[mid][0] <= target
  ? binsearch_impl(target, pairs, mid, hi)
  : binsearch_impl(target, pairs, lo, mid)
);
  
// Each element of 'slice' is a pair giving a Z-coordinate and a payload
// listof values. The result is a similar list with Z-coordinates spaced
// apart by 'zstep' and the payload values interpolated.
function smooth(zstep, slices) = (
  let (
    last_slice = len(slices)-1,
    minz = slices[0][0],
    maxz = slices[last_slice][0]
  )
  [
    for (z = [minz : zstep : maxz]) (
      // Edge cases: No interpolation.
      z == minz ? [z, slices[0][1]] :
      z == maxz ? [z, slices[last_slice][1]] :
    
      // Load the two bounding points between which to interpolate.
      let (
        lo = binsearch(z, slices),
    
        lower_z = slices[lo][0],
        lower_payload = slices[lo][1],
        upper_z = slices[lo+1][0],
        upper_payload = slices[lo+1][1],
    
        // Interpolation ratio.
        r = (z - lower_z) / (upper_z - lower_z)
      )
      [
        z,
        
        // Interpolate the payload.
        [
          for (i = [0:len(lower_payload)-1])
            upper_payload[i]*r + lower_payload[i]*(1-r)
        ]
      ]
    )
  ]
);

// Elements of 'list' are 3-tuples of center (X,Y) and radius.
module circles(list) {
  hull()
    for (tup = list)
      translate([tup[0], tup[1], 0])
        circle(tup[2]);
}
