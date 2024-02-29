CPU:

- m6809: stock in all machines, possibly m6809e, m68a09e, or
  m68b09e. m6009e is rated at 1 MHz, m68a09e 1.5MHz, and m68b09e at
  2MHz. All Color Computer 3 machines shipped with m68b09e or
  equivalent.

- h6309: common replacement (used in the late 80s, but extremely common
  today). Manufactured/sold as a drop in CMOS replacement with the
  addition of a C version (3MHz). In reality it was designed with a
  number of improvements which allow faster performance. It is also
  techincally 16-bits internally.

Systems:

- Dragon (various)/Color Computer 1/Color Computer 2: clocked at 0.89
  MHz ("slow"). Could be operated in 0.89/1.78 MHz ("fast")mode where it runs at
  1.78MHz which accessing routines in ROM or pure 1.78MHz mode. In
  1.78 MHz mode the screen is garbage and memory isn't refreshed.

- Color Computer 3: fully operational at both 0.89MHz ("slow") and
  1.78MHz ("fast").

Software:

- Color BASIC: 4-32k (64k). (Color Computer 1/2)

- Extended Color BASIC: 16-32k (64k) adds, in particular,
  support for graphics (Color Computer 1/2/Dragons)

- Super Extended Color BASIC: 128k adds support for some of the
  additional features of the GIME. (Color Computer 3), while the CoCo
  3 was oficially upgradable to 512k, SECB didn't really take
  advantage of the extra memory except for video. The code/variable
  for BASIC was restricted to 32k.

- Disk Extended Color BASIC: disk extensions for ECB or SECB.

- Dragon DOS: disk extensions for the Dragons.

- OS-9 Level I: an officially supported real OS for CoCos and Dragons
  with at least 64k of RAM. Basic09 was an additional package for this
  OS.

- OS-9 Level II: officially supported on CoCo 3. Adds support for MMU
  hardware. Each task can have its own 64k. On CoCo 3s runs at
  1.78MHz. Basic09 shepped with this OS (for the CoCo 3).

- NitrOS9: a rewrite of OS-9 originally to allow running a 6309 in
  native mode for faster operation. Eventually backported to support
  6809. Has Level I and II variants. Initially existed while CoCo 3
  was still in production. It is fairly common today.

- FLEX: another reasonably common 3rd party OS for the CoCo. Very
  similar to CP/M.

BASIC: Fast (Slow)

- Color Computer 1/2 or Dragon: 3:02 (4:15)

- Color Computer 3:   		2:12 (4:26)

Basic09: 6809 (6309) 		0:42 (0:31)

Assembly: 6809 (6309)

- Color Computer 1/2 or Dragon: 6.3 (2.7)

- Color Computer 3:   		3.3 (1.2)

Assembly - Hires: 6809 (6309)

- Color Computer 1/2 or Dragon (128x192):	4:06 (1:17)

- Color Computer 3 (320x200):  			5:59 (1:54)
