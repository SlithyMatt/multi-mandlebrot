hb63c09m:

The HB63C09 Completes asembly in 261 miliseconds (.261 Seconds) I beleve that is faster than the most recent Agon Light test, under asembly.

Computer is clocked at 20Mhz and has a wait state for serial (which is the only video output) so once the graphics expansion is completed 
it will be interesting to see how much faster the test completes without the serial io wait state.

CPU SPECS: 
 HD68C09 CPU running in native mode.
 system clock 20Mhz
 E strobe 5Mhz
 Serial output 
 MRDY is sent on every IO request and is cleared by the IO Controller.


I did not run the test without video output.

this code takes advantage of the speed tweeks avalible to the 6309 and uses the same maths in the ../6x09 directory that the Coco uses.
