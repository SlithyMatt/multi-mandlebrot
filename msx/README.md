MSX version
===========

Provides 3 variants:

1. Basic program 32x22 in 15 colors
2. Assembly language program 32x22 in 15 colors
3. Assembly language program 64x44 dithered using 4x4 monochrome chunks

For 32x22 variant program runs in screen mode 1. This mode has 32x24 characters
resolution in 15 colors. A feature of this mode is that the color of characters
tied not to a location on the screen but to character code itself and is defined
for eight consecutive characters simultaneously.

To imitate 8x8 'pixels', 15 color codes for characters 128-255 is redefined in the
way that foreground and background colors of a character are the same. Then character
with appropriate code is put to screen memory. Because foreground and background
colors are the same, characters are seen as color squares.

64x44 variant uses screen mode 2 in a straightforward way.

Running
-------

Is is highly recommended free and open sourced **openMSX** emulator to run these programs.
There were several hundred MSX-compatible models, **openMSX** can emulate almost every of
them. Rom images is not included, so must be found separately. A model with floppy is
desirable or a floppy extension must be activated. Such models as *National CF-3300* and
*Philips VG-8000* with *Philips NMS-1200* floppy controller has been tested and work fine.

Also tested *Turbo-R* machine *Panasonic FS-A1GT* with modified R800 CPU at 8mHz. Works
fine and awesome fast. Can be on par with modern *X16* and *ZX-Next*.

**OpenMSX** can mount a host directory as s virtual floppy, so fiddling with image files
isn't needed.

### Examples to run **openMSX**

- *National CF-3300*

```
   openmsx -machine National_CF-3300 -diska ./msx/
```

- *Philips VG-8000* + *Philips NMS-1200*

```
    openmsx -machine Philips_VG_8000 -ext Philips_NMS_1200 -diska ./msx/
```

- *Panasonic FS-A1GT*

```
    openmsx -machine Panasonic_FS-A1GT -diska ./msx/
```

After start, type `files` command to ensure that virtual floppy mounted correctly.

To load basic program, type `load"msx-mand.bas"` then `run`.

To load binary program type `bload"mand.bin",r` or `bload"mand2.bin",r`, they will run
automatically.

Other emulators need image file for emulated floppy drive. It can be created using
*msxdiskimage* utility can be downloaded from
[here](https://www.msx.org/downloads/dsk-and-xsa-image-utility-linux-and-windows)
