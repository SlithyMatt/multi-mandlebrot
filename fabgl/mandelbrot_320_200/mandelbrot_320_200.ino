#include "fabgl.h"

fabgl::VGAController dc;
fabgl::Canvas        canvas(&dc);
fabgl::PS2Controller ps2c;
bool written = false;


void setup() {
  ps2c.begin(PS2Preset::KeyboardPort0_MousePort1, KbdMode::GenerateVirtualKeys);

  dc.begin();
  dc.setResolution(VGA_320x200_75Hz);
  canvas.setBrushColor(0,0,2);
  canvas.selectFont(&fabgl::FONT_8x8);
  canvas.setPenColor(2,2,2);
}

void loop() {
  if (ps2c.keyboard()->isVKDown(fabgl::VK_RETURN)) {
    canvas.clear();
    written = false;
  } else if (!written) {
    canvas.clear();
    canvas.drawText(100,80,"Hit ENTER when ready...");
    written = true;
  }
}
