// Physical Keygen - by Nirav Patel <http://eclecti.cc>
//
// Generate a duplicate of a Schlage SC1 key by editing the last line of the file
// and entering in the key code of the lock.  If you don't know the key code,
// you can measure the key and compare the numbers at:
// http://web.archive.org/web/20050217020917fw_/http://dlaco.com/spacing/tips.htm
//
// This work is licensed under a Creative Commons Attribution 3.0 Unported License.

// Since the keys and locks I have were all designed in imperial units, the
// constants in this file will be defined in inches.  The mm function
// allows us to retain the proper size for exporting a metric STL.
function mm(i) = i*25.4;

// Higher definition curves
$fs = 0.01;

module roundedCube(dim, r=1, x=false, y=false, z=true, xcorners=[true,true,true,true], ycorners=[true,true,true,true], zcorners=[true,true,true,true], $fn=128)
{
	difference()
	{
		cube(dim);

		if(z)
		{
			translate([0, 0, -0.1])
			{
				if(zcorners[0])
					translate([0, dim[1]-r]) { rotateAround([0, 0, 90], [r/2, r/2, 0]) { meniscus(h=dim[2], r=r, fn=$fn); } }
				if(zcorners[1])
					translate([dim[0]-r, dim[1]-r]) { meniscus(h=dim[2], r=r, fn=$fn); }
				if(zcorners[2])
					translate([dim[0]-r, 0]) { rotateAround([0, 0, -90], [r/2, r/2, 0]) { meniscus(h=dim[2], r=r, fn=$fn); } }
				if(zcorners[3])
					rotateAround([0, 0, -180], [r/2, r/2, 0]) { meniscus(h=dim[2], r=r, fn=$fn); }
			}
		}

		if(y)
		{
			translate([0, -0.1, 0])
			{
				if(ycorners[0])
					translate([0, 0, dim[2]-r]) { rotateAround([0, 180, 0], [r/2, 0, r/2]) { rotateAround([-90, 0, 0], [0, r/2, r/2]) { meniscus(h=dim[1], r=r); } } }
				if(ycorners[1])
					translate([dim[0]-r, 0, dim[2]-r]) { rotateAround([0, -90, 0], [r/2, 0, r/2]) { rotateAround([-90, 0, 0], [0, r/2, r/2]) { meniscus(h=dim[1], r=r); } } }
				if(ycorners[2])
					translate([dim[0]-r, 0]) { rotateAround([-90, 0, 0], [0, r/2, r/2]) { meniscus(h=dim[1], r=r); } }
				if(ycorners[3])
					rotateAround([0, 90, 0], [r/2, 0, r/2]) { rotateAround([-90, 0, 0], [0, r/2, r/2]) { meniscus(h=dim[1], r=r); } }
			}
		}

		if(x)
		{
			translate([-0.1, 0, 0])
			{
				if(xcorners[0])
					translate([0, dim[1]-r]) { rotateAround([0, 90, 0], [r/2, 0, r/2]) { meniscus(h=dim[1], r=r); } }
				if(xcorners[1])
					translate([0, dim[1]-r, dim[2]-r]) { rotateAround([90, 0, 0], [0, r/2, r/2]) { rotateAround([0, 90, 0], [r/2, 0, r/2]) { meniscus(h=dim[1], r=r); } } }
				if(xcorners[2])
					translate([0, 0, dim[2]-r]) { rotateAround([180, 0, 0], [0, r/2, r/2]) { rotateAround([0, 90, 0], [r/2, 0, r/2]) { meniscus(h=dim[1], r=r); } } }
				if(xcorners[3])
					rotateAround([-90, 0, 0], [0, r/2, r/2]) { rotateAround([0, 90, 0], [r/2, 0, r/2]) { meniscus(h=dim[1], r=r); } }
			}
		}
	}
}

module meniscus(h, r, fn=128)
{
	$fn=fn;

	difference()
	{
		cube([r+0.2, r+0.2, h+0.2]);
		translate([0, 0, -0.1]) { cylinder(h=h+0.4, r=r); }
	}
}

module rotateAround(a, v) { translate(v) { rotate(a) { translate(-v) { children(); } } } }
module rounded(size, r) {
    union() {
        translate([r, 0, 0]) cube([size[0]-2*r, size[1], size[2]]);
        translate([0, r, 0]) cube([size[0], size[1]-2*r, size[2]]);
        translate([r, r, 0]) cylinder(h=size[2], r=r);
        translate([size[0]-r, r, 0]) cylinder(h=size[2], r=r);
        translate([r, size[1]-r, 0]) cylinder(h=size[2], r=r);
        translate([size[0]-r, size[1]-r, 0]) cylinder(h=size[2], r=r);
    }
}

module bit() {
    w = mm(1/4);
    difference() {
        translate([-w/2, 0, 0]) cube([w, mm(1), w]);
        translate([-mm(7/256), 0, 0]) rotate([0, 0, 135]) cube([w, w, w]);
         translate([mm(7/256), 0, 0]) rotate([0, 0, -45]) cube([w, w, w]);
    }
}

// Schlage SC1 5 pin key.  The measurements are mostly guesses based on reverse
// engineering some keys I have and some publicly available information.
module sc1(bits, id) {
    
    // You may need to adjust these to fit your specific printer settings
    thickness = mm(0.080);
    length = mm(17/16);
    width = mm(.335);
    
    shoulder = mm(.231);
    pin_spacing = mm(.156);
    depth_inc = mm(.015);
    
    // A fudge factor.  Printing with your average RepRap, the bottom layer is
    // going to be squeezed larger than you want. You can make the pins
    // go slighly deeper by a fudge amount to make up for it if you aren't
    // adjusting for it elsewhere like Skeinforge or in your firmware.
    // 0.5mm works well for me.
    fudge = 0.5;
    
    // Handle size
    h_l = mm(0.7);
    h_w = mm(0.5);
    h_d = mm(1/16);
    difference() {
        // blade and key handle
        union() {
            //roundedCube(dim, r=1, x=false, y=false, z=true, xcorners=[true,true,true,true], ycorners=[true,true,true,true], zcorners=[true,true,true,true], $fn=128)
            translate([-h_l, -h_w/2 + width/2, 0]) roundedCube([h_l, h_w, thickness], mm(1/16));
            
              // add text
    rotate([180,0,0]) translate([-h_l/1.15, -7, 0]) linear_extrude(0.2) text(str(id), mm(4/16));

            intersection() {
                // cut a little off the tip to avoid going too long
                cube([length - mm(1/64), width, thickness]);
                translate([0, mm(1/4), thickness*3/4]) rotate([0, 90, 0]) cylinder(h=length, r=mm(1/4), $fn=64);
            }
        }
        
        // chamfer the tip
        translate([length, mm(1/8), 0]) {
            rotate([0, 0, 45]) cube([10, 10, thickness]);
            rotate([0, 0, 225]) cube([10, 10, thickness]);
        }
        
        // put in a hole for keychain use
      //  translate([-h_l + mm(3/16), width/2, 0]) cylinder(h=thickness, r=mm(1/8));
        
        // cut the channels in the key.  designed more for printability than accuracy
        union() {
            translate([-h_d, mm(9/64), thickness/2]) rotate([62, 0, 0]) cube([length + h_d, width, width]);
            translate([-h_d, mm(7/64), thickness/2]) rotate([55, 0, 0]) cube([length + h_d, width, width]);
            translate([-h_d, mm(7/64), thickness/2]) cube([length + h_d, mm(1/32), width]);
        }
        
        translate([-h_d, width - mm(9/64), 0]) cube([length + h_d, width - (width - mm(10/64)), thickness/2]);
        translate([-h_d, width - mm(9/64), thickness/2]) rotate([-110, 0, 0]) cube([length + h_d, width, thickness/2]);
        
        intersection() {
            translate([-h_d, mm(1/32), thickness/2]) rotate([-118, 0, 0]) cube([length + h_d, width, width]);
            translate([-h_d, mm(1/32), thickness/2]) rotate([-110, 0, 0]) cube([length + h_d, width, width]);
        }
        
        // Do the actual bitting
        for (b = [0:4]) {
            translate([shoulder + b*pin_spacing, width - bits[b]*depth_inc - fudge, 0]) bit();
        }
    }
  
}

// This sample key goes to a lock that is sitting disassembled on my desk
// Flip the key over for easy printing
keysize = 55;
keywidth = 20;

// The "Original key"
translate([0,-30,0]) rotate([180, 0, 0]) sc1(3, 3, 1, 7, 2,"O");
