### Mandelbrot for Modern Macs (Apple Silicon)

A native AppKit app written in Swift. The plot is computed on all CPU cores at
full Retina resolution and can be panned and zoomed interactively; each change
replots the visible region. It uses the same palette as the [modern](../../modern)
C++ implementation, and the status overlay shows the render time.

- main.swift - The complete source code.
- build.sh - Builds `Mandelbrot.app`. Requires only the Xcode Command Line Tools (`xcode-select --install`).

```
./build.sh
open Mandelbrot.app
```

#### Controls

| Action | Input |
| --- | --- |
| Pan | Drag, two-finger trackpad scroll, or arrow keys |
| Zoom at cursor | Pinch, mouse wheel, or Command + scroll |
| Zoom in / out 2x | Double-click / Option + double-click, or `+` / `-` |
| More / fewer iterations | `]` / `[` |
| Reset view | `0` or `r` |

The iteration limit increases automatically as you zoom in. Zooming stops at
about 10^-15 units per point, the limit of double precision.
