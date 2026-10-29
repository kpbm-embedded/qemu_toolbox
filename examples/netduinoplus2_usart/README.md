# netduinoplus2_usart

STM32F405RG on QEMU's `netduinoplus2`: a polling USART1 driver whose output appears on stdio
(`-serial stdio` maps to USART1). QEMU has no STM32F411 machine; the F405 is the closest and its
USART registers match the BlackPill F411 (on hardware add the RCC clock and PA9/PA10 AF7 setup).
QEMU's STM32 models are thin (USART, timers, SYSCFG, EXTI, ADC/SPI partly); RCC and GPIO are
mostly unimplemented, so peripheral-heavy code belongs in Renode (32_06_renode).
