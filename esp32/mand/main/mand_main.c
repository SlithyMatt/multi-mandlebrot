#include <stdio.h>
#include <inttypes.h>
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_chip_info.h"
#include "esp_flash.h"
#include "esp_system.h"

void app_main(void)
{
    TickType_t start_ticks = xTaskGetTickCount();

    char *pixels = "#$@{[(/*<=o~:. ";
    for (int py = 0; py < 22; py++)
    {
        for (int px = 0; px < 32; px++)
        {
            double xz = px*3.5/32.0-2.5;
            double yz = py*2.0/22.0-1.0;
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
            putchar(pixels[i-1]);
        }
        putchar('\n');
    }

    TickType_t stop_ticks = xTaskGetTickCount();
    int time = (stop_ticks-start_ticks)*1000/configTICK_RATE_HZ;
    printf("\nTime to plot: %d milliseconds\n\n",time);
}
