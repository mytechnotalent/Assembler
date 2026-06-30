# ===================================================================
# Project:       AVR Assembler Lessons - Lesson 003
# Author:        Kevin Thomas
# Version:       1.0.0
# Date:          2026-06-28
# Target Device: ATmega328P
# Clock Freq:    16 MHz
# Toolchain:     avr-as, avr-ld, avrdude
# ===================================================================

MCU     = atmega328p
LD_ARCH = avr5
F_CPU   = 16000000
TARGET  = lesson

AS      = avr-as
LD      = avr-ld
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE    = avr-size

PROGRAMMER = arduino
BAUD       = 115200

ASFLAGS = -mmcu=$(MCU)
LDFLAGS = -m $(LD_ARCH)

all: $(TARGET).hex
	@$(SIZE) $(TARGET).elf

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

$(TARGET).elf: $(TARGET).o
	$(LD) $(LDFLAGS) -o $@ $^

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

flash: $(TARGET).hex
	@PORT=""; \
	case `uname` in \
	  Darwin*)  PORT=`ls /dev/cu.usbmodem* /dev/tty.usbmodem* 2>/dev/null | head -1`;; \
	  Linux*)   PORT=`ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | head -1`;; \
	  MINGW*|MSYS*) PORT=`ls /dev/ttyS* 2>/dev/null | head -1`;; \
	esac; \
	if [ -z "$$PORT" ]; then \
	  echo "Error: no Arduino serial port found"; \
	  echo "Try: avrdude -c $(PROGRAMMER) -p $(MCU) -P <PORT> -b $(BAUD) -U flash:w:$<"; \
	  exit 1; \
	fi; \
	echo "Found port: $$PORT"; \
	avrdude -c $(PROGRAMMER) -p $(MCU) -P "$$PORT" -b $(BAUD) -U flash:w:$<

usbtiny: $(TARGET).hex
	avrdude -c usbtiny -p $(MCU) -U flash:w:$<

disasm: $(TARGET).elf
	$(OBJDUMP) -h -d $< > $(TARGET).lss

clean:
	rm -f $(TARGET).elf $(TARGET).hex $(TARGET).lss $(TARGET).o
