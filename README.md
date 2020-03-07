# master-key-decoder

This implements Matt Blaze's algorithm for recovering the code for
the master key from locks (physical locks :) that are part of a
master keying system, used in many business environments.

It does so by printing all the keys you need to decode the lock, so you
don't have to file down masters.

## Warnings

3D printed keys are not very durable, and if your lock is stiff, you could easily break off a key in the lock.  Use with care!

## HOWTO

To use, enter your code into the "bits" array of mkg.rb and run the script

Append the output to sc1.scad and use OpenSCAD to generate an STL.

Slice / Print the STL.

Once you've tried every key in your lock, and found all the ones that work,
enter the resulting code into the sca1.scad file, and print that.  Tada!
