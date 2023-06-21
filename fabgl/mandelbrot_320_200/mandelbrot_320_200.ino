#include "fabgl.h"

fabgl::VGAController dc;
fabgl::Canvas        canvas(&displayController);
fabgl::PS2Controller ps2c;

class PlotScene : public Scene {
  PlotScene() : Scene(0,20,dc.getViewPortWidth(),dc.getViewPortHeight()) {    
  }

  if (ps2controller.keyboard()->isVKDown(fabgl::VK_RETURN)) {
    canvas.clear();
    written = false;
  } else if (!written) {
    canvas.setBrushColor(0,0,2);
    canvas.clear();
    canvas.selectFont(&fabgl::FONT_8x8);
    canvas.setPenColor(2,2,2);
    canvas.drawText(100,80,"Hit ENTER when ready...");
    written = true;
  }
}

void setup() {
  ps2controller.begin(PS2Preset::KeyboardPort0_MousePort1, KbdMode::GenerateVirtualKeys);

  displayController.begin();
  displayController.setResolution(VGA_320x200_75Hz);
}

void loop() {
   PlotScene scene;
   scene.start();
}
