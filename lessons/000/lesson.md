# Lesson 000 - Hello Blinky World

## This lesson will teach you how to make an LED blink on an ATmega328P using pure AVR assembly, from writing the code to uploading it onto the microcontroller.

[CODE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/000/lesson.s)

Welcome to your very first microcontroller program! By the end of this lesson, you will
make an LED blink using nothing but assembly language — the closest thing to talking
directly to the silicon.

---

## What You Will Learn

- What a microcontroller is and how it thinks
- What assembly language looks like and why we use it
- How to set up the stack pointer (the micro's memory manager)
- How to turn a pin on and off
- How a delay loop wastes time so the blink is visible
- How to build and upload your program

---

## What Is a Microcontroller?

Imagine a tiny computer that fits on your fingernail. It has its own memory, its own
brain (called a **CPU**), and a bunch of metal legs called **pins** that can sense the
outside world or control things like lights and motors. That is a **microcontroller**.

The chip we are using is the **ATmega328P** running at **16 MHz** (16 million
instructions per second) on the Arduino / Elegoo Uno R3. That is crazy fast —
it blinks so fast you would not even see it. That is why we need a **delay loop**
to slow it down.

---

## What Is Assembly Language?

Computers only understand **ones and zeros** — machine code. But writing ones and zeros
is horrible for humans. So we invented **assembly language**, which lets us write short
English-like words (like `LDI`, `OUT`, `RJMP`) that a program called an **assembler**
turns into ones and zeros for us.

Every line of assembly usually does one tiny thing: load a number, add two numbers, or
turn a pin on. You have to tell the computer *every single step*. It is like giving a
friend a recipe where you have to say "pick up the spoon, move it to the bowl, tilt it,
let the sugar fall out, put the spoon down." But the reward is total control — and you
truly understand what the computer is doing.

---

## What Is an LED?

LED stands for **Light Emitting Diode**. It is a tiny light bulb that only lets
electricity flow one way. The long leg (anode) connects to positive, the short leg
(cathode) connects to ground through a **resistor** (to keep it from burning out).

On the ATmega328P, pin **PB5** (Port B, pin 5) is connected to the built-in LED on
many boards. When PB5 is **HIGH** (5 volts), current flows through the LED and it
lights up. When PB5 is **LOW** (0 volts), no current flows and the LED turns off.
So we set the pin *high* to turn the LED *on*.

---

## The Circuit

You only need a few parts:

```
        ATmega328P
     +-------------+
     |             |
     |          PB5|----[220Ω]----[LED]----GND
     |             |
     +-------------+
```

- The resistor limits the current so the LED does not pop.
- The LED cathode (short leg, flat side) goes to GND.
- The LED anode (long leg) connects through the resistor to PB5.

If you are using an Arduino Uno, the built-in LED on pin 13 is already connected to
PB5. So you do not even need a breadboard for this lesson!

### About the Elegoo / Arduino Uno R3

The **Elegoo Uno R3** is a 100% compatible clone of the **Arduino Uno R3**. Both use:

- **ATmega328P** microcontroller
- **16 MHz** external crystal (the silver oval component near the big chip)
- **Built-in LED** on pin 13, which is wired to **PB5** (Port B, pin 5)
- **No built-in user button** (the only button on the board is the RESET button)

We just set the chip's fuses to `0xFF / 0xDE / 0xFD` — the standard Arduino Uno
configuration — so it uses the external 16 MHz crystal and runs the bootloader,
just like a factory-fresh board.

---

## The Code — Line by Line

Here is the full program. Do not worry if it looks confusing — we will walk through
every single piece.

### 1. The Header

```
; ==============================================================================
; Project:       AVR Assembler Lessons
; Author:        Kevin Thomas
; Version:       1.0.0
; Date:          2026-06-28
; Target Device: ATmega328P
; Clock Freq:    16 MHz
; Toolchain:     avr-as, avr-ld, avrdude
; Description:   Lesson 000 - Hello Blinky World
; ==============================================================================
```

Lines that start with a semicolon (`;`) are **comments**. The assembler ignores them.
They are just notes for humans. Every good program starts with a header that says what
it is, who wrote it, and what it does.

### 2. The Section Declaration

```
.section .text
```

This tells the assembler "what follows is program code, not data." All our instructions
will live in the **.text** section of the chip's flash memory. Flash memory does not
forget when the power is turned off — so your program is saved forever.

### 3. The DEFINES

```
.equ RAMEND, 0x08FF                     ; Last SRAM address (ATmega328P)
.equ SPL,    0x3D                       ; Stack Pointer Low register
.equ SPH,    0x3E                       ; Stack Pointer High register
.equ DDRB,   0x04                       ; Port B Data Direction Register
.equ PORTB,  0x05                       ; Port B Data Register
.equ PB5,    5                          ; Port B Pin 5 (built-in LED)
```

`.equ` is short for "equate." It lets us give a name to a number so the code is easier
to read. Instead of remembering that `0x04` is the Data Direction Register for Port B,
we just write `DDRB`. The assembler replaces `DDRB` with `0x04` automatically.

| Name | Value | What It Is |
|------|-------|------------|
| `RAMEND` | `0x08FF` | The last byte of memory (2 KB of SRAM) |
| `SPL` | `0x3D` | Stack Pointer Low byte (I/O register address) |
| `SPH` | `0x3E` | Stack Pointer High byte (I/O register address) |
| `DDRB` | `0x04` | Data Direction Register for Port B |
| `PORTB` | `0x05` | Data Register for Port B (set pins HIGH or LOW) |
| `PB5` | `5` | Pin 5 on Port B — the LED pin |

### 4. The Reset Vector

```
.org 0x0000                             ; Program starts at address 0
  RJMP   main                           ; Jump to main program
```

When the chip first turns on (or is reset), it looks at address `0x0000` and runs
whatever instruction it finds there. `.org 0x0000` says "put the next instruction at
address 0." `RJMP main` says "jump to the part of the program called `main`."

Think of it like a book's table of contents: "Start on page 1, then skip to chapter 1."

### 5. The main Subroutine

```
main:                             
  LDI    R16, lo8(RAMEND)               ; R16 = low byte of last RAM address
  OUT    SPL, R16                       ; Stack Pointer Low = R16
  LDI    R16, hi8(RAMEND)               ; R16 = high byte of last RAM address
  OUT    SPH, R16                       ; Stack Pointer High = R16
  SBI    DDRB, PB5                      ; DDRB bit 5 = 1, PB5 becomes an output
```

**`main:`** is a **label**. It is a name we give to a spot in the program so we can
jump to it. Labels end with a colon (`:`).

**`LDI R16, lo8(RAMEND)`** — Load Immediate into register R16. R16 is one of 32
temporary holding places inside the CPU called **registers**. They are like the
scratch paper on your desk — super fast to use, but very few of them.

`lo8(RAMEND)` means "the low 8 bits of RAMEND." RAMEND is `0x08FF`. In binary:
`0000 1000 1111 1111`. The low 8 bits are `1111 1111` = `0xFF`. The high 8 bits are
`0000 1000` = `0x08`.

```
RAMEND = 0x08FF
           ^high  ^low
```

**Why do we need the stack pointer?** When you call a subroutine with `RCALL`, the
chip needs to remember where it was so it can come back. It writes that address on
the **stack** — a section of RAM set aside for bookkeeping. The **stack pointer**
(SPL + SPH) keeps track of where the next free spot on the stack is. We have to tell
it where the top of RAM is (`RAMEND`) before we can use `RCALL` or `RET`.

**`SBI DDRB, PB5`** — Set Bit in I/O register. This sets bit 5 of the DDRB register
to 1. DDRB stands for **Data Direction Register B**. Each bit controls whether a pin
is an input (0) or an output (1). Setting bit 5 to 1 makes PB5 an output pin so it
can drive the LED.

### 6. The Main Loop

```
.loop:                            
  SBI    PORTB, PB5                     ; PB5 = 1, LED turns ON 
  RCALL  delay                          ; Wait exactly half a second
  CBI    PORTB, PB5                     ; PB5 = 0, LED turns OFF
  RCALL  delay                          ; Wait exactly half a second
  RJMP   .loop                          ; Jump back and blink forever
```

**`.loop:`** is another label, this time marking the start of our blinking loop.

**`SBI PORTB, PB5`** — Set Bit in I/O register. This sets bit 5 of PORTB to 1
(HIGH). The LED turns ON.

**`RCALL delay`** — Relative Call to the `delay` subroutine. The chip writes the
address of the next instruction on the stack and jumps to `delay`. When `delay` hits
a `RET` instruction, it reads the address back off the stack and continues here.
This is like putting a bookmark in your book before going to check something in the
kitchen — the bookmark tells you where to return.

**`CBI PORTB, PB5`** — Clear Bit in I/O register. This sets bit 5 of PORTB to 0
(LOW). The LED turns OFF.

**`RJMP .loop`** — Relative Jump back to `.loop`. This is the forever part. The
program runs around this loop endlessly, blinking the LED forever.

### 7. The delay Subroutine

```
delay:                            
  LDI    R18, 0x18                      ; 24-bit counter High Byte (1599998)
  LDI    R17, 0x69                      ; 24-bit counter Mid Byte
  LDI    R16, 0xFE                      ; 24-bit counter Low Byte
.d_loop:                          
  SUBI   R16, 1                         ; Subtract 1 from Low Byte
  SBCI   R17, 0                         ; Subtract carry from Mid Byte
  SBCI   R18, 0                         ; Subtract carry from High Byte
  BRNE   .d_loop                        ; Branch if the 24-bit result != 0
  NOP                                   ; Padding to get exactly 8M cycles
  RET                                   ; Return to caller
```

This is the trickiest part. The micro is so fast that if we just blinked without
waiting, it would turn on and off millions of times per second — invisible to our
eyes. So we need to waste time.

We do that with a **24-bit countdown loop**. The ATmega328P is an 8-bit chip, so 
we combine three 8-bit registers (R16, R17, and R18) to hold a massive 24-bit 
number: 1,599,998 (which is `0x1869FE` in hex).

- **`SUBI`** (Subtract Immediate) subtracts 1 from the lowest byte.
- **`SBCI`** (Subtract with Carry) subtracts 0, but it *also* subtracts the carry 
  flag if the previous byte rolled under 0. This elegantly chains the three bytes 
  together into one big countdown.

Each iteration of this 24-bit loop takes exactly 5 clock cycles:

```
1,599,998 loops × 5 cycles = 7,999,990 cycles
```

Add in the setup `LDI` commands, the function call overhead, and the `NOP` (No Operation) 
padding, and we hit exactly **8,000,000 cycles**. 

```
8,000,000 ÷ 16,000,000 Hz = 0.50 seconds
```

Exactly half a second! That is why the LED blinks at a nice, visible pace.

| Instruction | What It Does |
|-------------|-------------|
| `SUBI R16, 1` | Subtract 1 from the low byte |
| `SBCI R17, 0` | Subtract the carry flag from the middle byte |
| `SBCI R18, 0` | Subtract the carry flag from the high byte |
| `BRNE .d_loop` | If the combined 24-bit result is not zero, loop again |
| `NOP` | "No Operation" - wastes 1 clock cycle to perfect the timing |
| `RET` | Return to whoever called `delay` (back to `.loop`) |

### 8. The Return

```
  RET                                   ; Return to caller
```

`RET` stands for **return from subroutine**. It pops the return address off the stack
and jumps back to the instruction after `RCALL delay` in the main loop. Then the
blinking continues.

---

## Putting It All Together

Here is the whole flow, step by step:

```
Power on  ──►  .org 0x0000  ──►  RJMP main
                                      │
                                      ▼
                                    main:
                                      │
                                      ├── Set up stack pointer (SPL, SPH)
                                      │
                                      ├── Make PB5 an output (SBI DDRB, PB5)
                                      │
                                      ▼
                                  .loop:
                                      │
                                      ├── Turn LED ON   (SBI PORTB, PB5)
                                      ├── Wait 0.5s     (RCALL delay)
                                      ├── Turn LED OFF  (CBI PORTB, PB5)
                                      ├── Wait 0.5s     (RCALL delay)
                                      └── Go back to .loop (RJMP .loop)
                                                        │
                                                        ▼
                                                    blink forever!
```

---

## Building and Flashing

### Step 1: Assemble

Open a terminal and go to the lesson folder:

```bash
cd Assembler/lessons/000
make
```

You should see output like:

```
avr-as -mmcu=atmega328p -o lesson.o lesson.s
avr-ld -m avr5 -o lesson.elf lesson.o
avr-objcopy -j .text -j .data -O ihex lesson.elf lesson.hex
   text	   data	    bss	    dec	    hex	filename
     40	      0	      0	     40	     28	lesson.elf
```

The `lesson.hex` file is the final program the chip understands.

### Step 2: Flash

**Arduino serial bootloader**:

```bash
make flash
```

The Makefile will auto-detect the port on macOS, Linux, or Windows.

Congratulations — your chip is now running Hello Blinky World!

---

## Challenge Questions

1. What happens if you change `LDI R18, 0x18` to `LDI R18, 0x0C`? Try it!
2. What happens if you remove both `RCALL delay` lines? (Careful — you might not see
   the LED blink at all!)
3. What instruction would you use to turn the LED on and leave it on forever?
4. Why do we need the `.org 0x0000` line? What happens if we leave it out?
5. Can you change the program to blink 3 times fast, then pause? (Hint: add another
   set of loops inside `.loop`.)

---

## Words to Remember

| Term | Meaning |
|------|---------|
| **Microcontroller** | A tiny computer on one chip with CPU, memory, and I/O pins |
| **Assembly** | A human-readable version of machine code, one step above ones and zeros |
| **Register** | A super-fast temporary storage spot inside the CPU |
| **Stack** | A section of RAM used like a notebook to remember where we were |
| **Stack Pointer** | A counter that tracks the top of the stack |
| **Subroutine** | A reusable chunk of code you can call from multiple places |
| **Delay Loop** | A loop that does nothing useful except waste time |
| **LED** | Light Emitting Diode — a tiny light bulb |
| **Pin** | A metal leg on the chip you can read or control |
| **Assembler** | A program that turns assembly text into machine code |
| **Flash** | The non-volatile memory that holds your program |
| **DDR** | Data Direction Register — sets pins as input or output |
| **PORT** | Data Register — sets pins HIGH or LOW |

---

## What Is Next?

Now that you can blink an LED, you are ready for Lesson 001 — where you will learn
how to read a button and light the LED only when the button is pressed. From there,
you will build up to UART communication, timers, sensors, and even cryptography!

Every lesson builds on the one before it. Keep going — you are on your way to becoming
a true embedded engineer.
