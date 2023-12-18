date: 220130

[Purpose] heavy flowkey, 4-tuple, 5-tuple possible?

[Conclusion]
 - yes they are possible with both tofino1/tofino2
 - I made it possible by deleting diff_srcip, diff_dstip, etc but directly using !=.
 - This is really awesome!

[Tricks]
- amazing trick, reduce PHV dependency by hardcoded threshold.
- this is increadibly helpful, 
- we never guaranteeded dynamic thresholding in the paper.
- also trick of [31:31] is increadibly helpful as well -> it reduces PHV significantly.

[Dependency]
heavy_storage_test -> both_port_test