#include "ST7789.h"
#include "LVGL_Driver.h"

#define PIXEL_SCALE 1
#define XPLOT 160
#define YPLOT 110

lv_color_t palette[15];

void plot_pixel(lv_obj_t *canvas, int x, int y, int color)
{
    for (int xi = x*PIXEL_SCALE; xi < (x*PIXEL_SCALE+PIXEL_SCALE); xi++)
    {
        for (int yi = y*PIXEL_SCALE; yi < (y*PIXEL_SCALE+PIXEL_SCALE); yi++)
        {
            lv_canvas_set_px_color(canvas, xi, yi, palette[color]);
        }
    }
}

void app_main(void)
{
    TickType_t start_ticks = xTaskGetTickCount();
    LCD_Init();
    BK_Light(70);
    LVGL_Init();                            // returns the screen object

    palette[0] = lv_color_white();
    palette[1] = lv_palette_main(LV_PALETTE_RED);
    palette[2] = lv_palette_main(LV_PALETTE_PURPLE);
    palette[3] = lv_palette_main(LV_PALETTE_INDIGO);
    palette[4] = lv_palette_main(LV_PALETTE_BLUE);
    palette[5] = lv_palette_main(LV_PALETTE_LIGHT_BLUE);
    palette[6] = lv_palette_main(LV_PALETTE_CYAN);
    palette[7] = lv_palette_main(LV_PALETTE_GREEN);
    palette[8] = lv_palette_main(LV_PALETTE_LIGHT_GREEN);
    palette[9] = lv_palette_main(LV_PALETTE_YELLOW);
    palette[10] = lv_palette_main(LV_PALETTE_ORANGE);
    palette[11] = lv_palette_main(LV_PALETTE_BROWN);
    palette[12] = lv_palette_main(LV_PALETTE_BLUE_GREY);
    palette[13] = lv_palette_main(LV_PALETTE_GREY);
    palette[14] = lv_color_black();

    lv_obj_t *canvas = lv_canvas_create(lv_scr_act());
    lv_canvas_set_buffer(canvas,
        lv_mem_alloc(LV_CANVAS_BUF_SIZE_TRUE_COLOR(YPLOT*PIXEL_SCALE,XPLOT*PIXEL_SCALE)),
        YPLOT*PIXEL_SCALE,
        XPLOT*PIXEL_SCALE,
        LV_IMG_CF_TRUE_COLOR);
    lv_obj_center(canvas);

    for (int py = 0; py < YPLOT; py++)
    {
        for (int px = 0; px < XPLOT; px++)
        {
            double xz = px*3.5/(double)XPLOT-2.5;
            double yz = py*2.0/(double)YPLOT-1.0;
            double x = 0;
            double y = 0;
            int i;    
            for (i = 0; i < 15; i++)
            {
                if (x*x+y*y > 4.0)
                {
                    break;
                }
                double xt = x*x - y*y + xz;
                y = 2.0*x*y + yz;
                x = xt;
            }
            plot_pixel(canvas,py,px,i);
        }
    }

    TickType_t stop_ticks = xTaskGetTickCount();
    int time = (stop_ticks-start_ticks)*1000/configTICK_RATE_HZ;
    printf("\nTime to plot: %d milliseconds\n\n",time);

    while (1) {
        // raise the task priority of LVGL and/or reduce the handler period can improve the performance
        vTaskDelay(pdMS_TO_TICKS(10));
        // The task running lv_timer_handler should have lower priority than that running `lv_tick_inc`
        lv_timer_handler();
    }
}
