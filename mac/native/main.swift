// Mandelbrot for modern macOS (Apple Silicon)
// Interactive AppKit viewer: drag/scroll to pan, pinch/wheel/double-click to zoom.
// License: MIT

import AppKit

// MARK: - Palette

// Same palette scheme as ../../modern/mandelbrot.cpp: the 16 CGA colors,
// followed by repeating 16-step fades through the RGB primaries.
let cgaPalette: [(UInt8, UInt8, UInt8)] = [
    (0x00, 0x00, 0x00), (0x00, 0x00, 0xAA), (0x00, 0xAA, 0x00), (0x00, 0xAA, 0xAA),
    (0xAA, 0x00, 0x00), (0xAA, 0x00, 0xAA), (0xAA, 0x55, 0x00), (0xAA, 0xAA, 0xAA),
    (0x55, 0x55, 0x55), (0x55, 0x55, 0xFF), (0x55, 0xFF, 0x55), (0x55, 0xFF, 0xFF),
    (0xFF, 0x55, 0x55), (0xFF, 0x55, 0xFF), (0xFF, 0xFF, 0x55), (0xFF, 0xFF, 0xFF),
]

func rgba(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> UInt32 {
    // Bytes in memory: R, G, B, X (little-endian UInt32)
    UInt32(r) | UInt32(g) << 8 | UInt32(b) << 16 | 0xFF00_0000
}

func makePalette(count: Int) -> [UInt32] {
    var palette = [UInt32](repeating: 0, count: count)
    var r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0
    for i in 0..<count {
        if i < 16 {
            (r, g, b) = cgaPalette[i]
        } else if i % 16 == 0 {
            r = i & 0x10 != 0 ? 255 : 0
            g = i & 0x20 != 0 ? 255 : 0
            b = i & 0x40 != 0 ? 255 : 0
            if i & 0x70 == 0 {
                r = 255
                g = 128
            }
        } else {
            r = r > 16 ? r - 16 : 0
            g = g > 16 ? g - 16 : 0
            b = b > 16 ? b - 16 : 0
        }
        palette[i] = rgba(r, g, b)
    }
    palette[0] = rgba(0, 0, 0) // points inside the set map to 0
    return palette
}

// MARK: - Rendering

/// A region of the complex plane mapped onto a view, in view points.
struct Viewport {
    var centerX: Double
    var centerY: Double
    var scale: Double // complex units per point
    var width: Double // points
    var height: Double // points
}

struct RenderedImage {
    let image: CGImage
    let viewport: Viewport
    let maxIter: Int
    let pixelWidth: Int
    let pixelHeight: Int
    let seconds: Double
}

final class CancelToken: @unchecked Sendable {
    private let lock = NSLock()
    private var cancelled = false
    var isCancelled: Bool { lock.withLock { cancelled } }
    func cancel() { lock.withLock { cancelled = true } }
}

/// Computes the plot on all cores, one row per work item. Returns nil if cancelled.
func renderMandelbrot(_ vp: Viewport, pixelsPerPoint: Double, maxIter: Int,
                      palette: [UInt32], token: CancelToken) -> RenderedImage? {
    let start = DispatchTime.now()
    let w = max(1, Int((vp.width * pixelsPerPoint).rounded()))
    let h = max(1, Int((vp.height * pixelsPerPoint).rounded()))
    let step = vp.scale * vp.width / Double(w)
    let left = vp.centerX - vp.width / 2 * vp.scale
    let top = vp.centerY + vp.height / 2 * vp.scale

    var pixels = [UInt32](repeating: 0, count: w * h)
    pixels.withUnsafeMutableBufferPointer { buf in
        let base = buf.baseAddress!
        palette.withUnsafeBufferPointer { pal in
            DispatchQueue.concurrentPerform(iterations: h) { py in
                if token.isCancelled { return }
                let yz = top - (Double(py) + 0.5) * step
                let row = base + py * w
                for px in 0..<w {
                    let xz = left + (Double(px) + 0.5) * step
                    row[px] = pal[iterations(xz, yz, maxIter)]
                }
            }
        }
    }
    if token.isCancelled { return nil }

    let data = pixels.withUnsafeBufferPointer { Data(buffer: $0) } as CFData
    guard let provider = CGDataProvider(data: data),
          let image = CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32,
                              bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
                              provider: provider, decode: nil, shouldInterpolate: false,
                              intent: .defaultIntent)
    else { return nil }

    let seconds = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1e9
    return RenderedImage(image: image, viewport: vp, maxIter: maxIter, pixelWidth: w,
                         pixelHeight: h, seconds: seconds)
}

/// Escape iteration count for c = xz + yz*i, or 0 if it never escapes.
@inline(__always)
func iterations(_ xz: Double, _ yz: Double, _ maxIter: Int) -> Int {
    // Skip the main cardioid and period-2 bulb, which are always inside
    let xq = xz - 0.25
    let q = xq * xq + yz * yz
    if q * (q + xq) <= 0.25 * yz * yz { return 0 }
    if (xz + 1) * (xz + 1) + yz * yz <= 0.0625 { return 0 }

    var x = 0.0, y = 0.0
    var i = 0
    while i < maxIter {
        let x2 = x * x, y2 = y * y
        if x2 + y2 > 4 { return i }
        y = 2 * x * y + yz
        x = x2 - y2 + xz
        i += 1
    }
    return 0
}

// MARK: - View

final class MandelbrotView: NSView {
    // Default region matches the other implementations: real -2.5..1, imaginary -1..1
    private let homeX = -0.75, homeY = 0.0, homeWidth = 3.5, homeHeight = 2.3
    private let minScale = 1e-15 // limit of double precision

    private var centerX = -0.75
    private var centerY = 0.0
    private var scale = 0.0 // complex units per point; 0 until first layout
    private var iterBase = 256

    private var rendered: RenderedImage? // last full-resolution plot
    private var preview: RenderedImage? // low-resolution plot of the current viewport
    private var palette: [UInt32] = []
    private var token = CancelToken()
    private let renderQueue = DispatchQueue(label: "mandelbrot.render", qos: .userInitiated)
    private var lastDrag: NSPoint?
    var onStatusChange: ((String) -> Void)?

    override var acceptsFirstResponder: Bool { true }
    override var isOpaque: Bool { true }

    private var homeScale: Double {
        max(homeWidth / bounds.width, homeHeight / bounds.height)
    }

    /// Iteration limit grows with zoom depth so detail keeps resolving.
    private var maxIter: Int {
        let depth = max(0, log2(homeScale / scale))
        return iterBase + Int(depth * 64)
    }

    private var viewport: Viewport {
        Viewport(centerX: centerX, centerY: centerY, scale: scale,
                 width: bounds.width, height: bounds.height)
    }

    // MARK: Rendering

    private func scheduleRender() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        if scale == 0 { scale = homeScale }
        needsDisplay = true

        token.cancel()
        let token = CancelToken()
        self.token = token
        let vp = viewport
        let iter = maxIter
        if palette.count < iter { palette = makePalette(count: iter * 2) }
        let palette = self.palette
        let fullDensity = window?.backingScaleFactor ?? 2

        renderQueue.async { [weak self] in
            // Quick low-resolution pass for responsiveness, then full resolution
            for density in [fullDensity / 8, fullDensity] {
                guard let result = renderMandelbrot(vp, pixelsPerPoint: density, maxIter: iter,
                                                    palette: palette, token: token)
                else { return }
                let isPreview = density != fullDensity
                DispatchQueue.main.async {
                    guard let self, !token.isCancelled else { return }
                    if isPreview {
                        self.preview = result
                    } else {
                        self.rendered = result
                        self.preview = nil
                        self.updateStatus()
                    }
                    self.needsDisplay = true
                }
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.setFill()
        bounds.fill()
        guard let ctx = NSGraphicsContext.current?.cgContext, scale > 0 else { return }

        // While a new plot is computing, show the low-res preview underneath and the
        // last full plot mapped into the current viewport on top, so pans and zooms
        // get immediate feedback.
        if let p = preview { draw(p, in: ctx, interpolation: .medium) }
        if let r = rendered { draw(r, in: ctx, interpolation: preview == nil ? .none : .medium) }

        drawOverlay()
    }

    private func draw(_ r: RenderedImage, in ctx: CGContext, interpolation: CGInterpolationQuality) {
        let iv = r.viewport
        let originX = (iv.centerX - iv.width / 2 * iv.scale - (centerX - bounds.width / 2 * scale)) / scale
        let originY = (iv.centerY - iv.height / 2 * iv.scale - (centerY - bounds.height / 2 * scale)) / scale
        let dest = CGRect(x: originX, y: originY,
                          width: iv.width * iv.scale / scale, height: iv.height * iv.scale / scale)
        ctx.interpolationQuality = interpolation
        ctx.draw(r.image, in: dest)
    }

    private var statusText: String {
        let width = scale * bounds.width
        var text = String(format: "Center: %.15g %+.15gi    Width: %.6g    Zoom: %.4gx    Iterations: %d",
                          centerX, centerY, width, homeScale / scale, maxIter)
        if let r = rendered, preview == nil, !isStale(r) {
            text += String(format: "\nRender: %.1f ms  (%d x %d px, %d cores)",
                           r.seconds * 1000, r.pixelWidth, r.pixelHeight,
                           ProcessInfo.processInfo.activeProcessorCount)
        } else {
            text += "\nRendering…"
        }
        if scale <= minScale * 1.0001 { text += "    [precision limit]" }
        return text
    }

    private func isStale(_ r: RenderedImage) -> Bool {
        let v = r.viewport
        return v.centerX != centerX || v.centerY != centerY || v.scale != scale
            || v.width != bounds.width || v.height != bounds.height || r.maxIter != maxIter
    }

    private func drawOverlay() {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
            .foregroundColor: NSColor.white,
        ]
        let str = NSAttributedString(string: statusText, attributes: attrs)
        let size = str.size()
        let box = NSRect(x: 8, y: 8, width: size.width + 12, height: size.height + 8)
        NSColor(white: 0, alpha: 0.6).setFill()
        NSBezierPath(roundedRect: box, xRadius: 5, yRadius: 5).fill()
        str.draw(at: NSPoint(x: box.minX + 6, y: box.minY + 4))
    }

    private func updateStatus() {
        onStatusChange?(String(format: "Mandelbrot — %.4gx", homeScale / scale))
    }

    // MARK: Navigation

    private func zoom(by factor: Double, at point: NSPoint? = nil) {
        let p = point ?? NSPoint(x: bounds.midX, y: bounds.midY)
        let dx = Double(p.x - bounds.midX), dy = Double(p.y - bounds.midY)
        // Keep the complex coordinate under the cursor fixed
        let zx = centerX + dx * scale, zy = centerY + dy * scale
        scale = min(max(scale / factor, minScale), homeScale * 4)
        centerX = zx - dx * scale
        centerY = zy - dy * scale
        scheduleRender()
    }

    private func pan(dx: Double, dy: Double) {
        centerX -= dx * scale
        centerY -= dy * scale
        scheduleRender()
    }

    private func location(of event: NSEvent) -> NSPoint {
        convert(event.locationInWindow, from: nil)
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        scheduleRender()
    }

    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        scheduleRender()
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            let zoomOut = event.modifierFlags.contains(.option) || event.modifierFlags.contains(.shift)
            zoom(by: zoomOut ? 0.5 : 2, at: location(of: event))
        }
        lastDrag = location(of: event)
        NSCursor.closedHand.push()
    }

    override func mouseDragged(with event: NSEvent) {
        let p = location(of: event)
        if let last = lastDrag {
            pan(dx: Double(p.x - last.x), dy: Double(p.y - last.y))
        }
        lastDrag = p
    }

    override func mouseUp(with event: NSEvent) {
        lastDrag = nil
        NSCursor.pop()
    }

    override func scrollWheel(with event: NSEvent) {
        if event.hasPreciseScrollingDeltas && !event.modifierFlags.contains(.command) {
            // Trackpad two-finger scroll pans
            centerX -= Double(event.scrollingDeltaX) * scale
            centerY += Double(event.scrollingDeltaY) * scale
            scheduleRender()
        } else {
            // Mouse wheel (or Command+scroll) zooms around the cursor
            let delta = Double(event.scrollingDeltaY) * (event.hasPreciseScrollingDeltas ? 0.1 : 1)
            guard delta != 0 else { return }
            zoom(by: pow(1.15, delta), at: location(of: event))
        }
    }

    override func magnify(with event: NSEvent) {
        zoom(by: 1 + Double(event.magnification), at: location(of: event))
    }

    override func keyDown(with event: NSEvent) {
        let panStep = Double(min(bounds.width, bounds.height)) * 0.1
        switch event.specialKey {
        case .leftArrow: pan(dx: panStep, dy: 0)
        case .rightArrow: pan(dx: -panStep, dy: 0)
        case .upArrow: pan(dx: 0, dy: -panStep)
        case .downArrow: pan(dx: 0, dy: panStep)
        default:
            switch event.charactersIgnoringModifiers {
            case "+", "=": zoomIn(nil)
            case "-", "_": zoomOut(nil)
            case "0", "r": resetView(nil)
            case "]": moreIterations(nil)
            case "[": fewerIterations(nil)
            default: super.keyDown(with: event)
            }
        }
    }

    // MARK: Menu actions

    @objc func zoomIn(_ sender: Any?) { zoom(by: 2) }
    @objc func zoomOut(_ sender: Any?) { zoom(by: 0.5) }

    @objc func resetView(_ sender: Any?) {
        centerX = homeX
        centerY = homeY
        scale = homeScale
        iterBase = 256
        scheduleRender()
    }

    @objc func moreIterations(_ sender: Any?) {
        iterBase = min(iterBase * 2, 1 << 20)
        scheduleRender()
    }

    @objc func fewerIterations(_ sender: Any?) {
        iterBase = max(iterBase / 2, 16)
        scheduleRender()
    }
}

// MARK: - App

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()

        let view = MandelbrotView(frame: NSRect(x: 0, y: 0, width: 1050, height: 690))
        window = NSWindow(contentRect: view.frame,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Mandelbrot"
        window.contentView = view
        window.contentMinSize = NSSize(width: 320, height: 200)
        window.makeFirstResponder(view)
        window.center()
        window.setFrameAutosaveName("MandelbrotWindow")
        view.onStatusChange = { [weak self] title in self?.window.title = title }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    private func buildMenu() {
        let mainMenu = NSMenu()

        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Mandelbrot",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide Mandelbrot", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "Quit Mandelbrot", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)

        let viewItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Zoom In", action: #selector(MandelbrotView.zoomIn(_:)), keyEquivalent: "+")
        viewMenu.addItem(withTitle: "Zoom Out", action: #selector(MandelbrotView.zoomOut(_:)), keyEquivalent: "-")
        viewMenu.addItem(withTitle: "Reset View", action: #selector(MandelbrotView.resetView(_:)), keyEquivalent: "0")
        viewMenu.addItem(.separator())
        viewMenu.addItem(withTitle: "More Iterations", action: #selector(MandelbrotView.moreIterations(_:)), keyEquivalent: "]")
        viewMenu.addItem(withTitle: "Fewer Iterations", action: #selector(MandelbrotView.fewerIterations(_:)), keyEquivalent: "[")
        viewMenu.addItem(.separator())
        viewMenu.addItem(withTitle: "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
            .keyEquivalentModifierMask = [.command, .control]
        viewItem.submenu = viewMenu
        mainMenu.addItem(viewItem)

        let windowItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowItem.submenu = windowMenu
        mainMenu.addItem(windowItem)
        NSApp.windowsMenu = windowMenu

        NSApp.mainMenu = mainMenu
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
