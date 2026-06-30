# Lesson 001 - Hello Button World

## This lesson will teach you how to read a button press to turn on an LED on an ATmega328P using pure AVR assembly.

[CODE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/001/lesson.s)

Welcome to your second microcontroller program! In this lesson, we will move beyond just turning an LED on and off by ourselves. We will read the real world — a button press — and use it to control the LED.

---

## What You Will Learn

- How to read a digital input from a pin
- What a pull-up resistor is and why you need it
- How to use conditional branches to make decisions in code
- The difference between `PORT` registers and `PIN` registers

---

## What Is a Pull-Up Resistor?

When a microcontroller pin is set as an input, it is extremely sensitive to electrical noise. If nothing is connected to it, it is "floating" and might randomly read as HIGH (1) or LOW (0) just from the static electricity in the air!

To fix this, we need to tie the pin to a known voltage. A **pull-up resistor** connects the pin to 5V. When the button is NOT pressed, the pin reads HIGH. When you press the button, it connects the pin to ground (GND), overpowering the resistor, and the pin reads LOW.

The ATmega328P has built-in pull-up resistors on every pin! We just have to turn them on in code.

---

## The Circuit

You will need:
- Your Arduino/Elegoo Uno R3
- 1 small button
- 2 jumper wires
- A breadboard

```
        ATmega328P
     +-------------+
     |             |
     |          PD2|----[Button]----GND
     |             |
     |          PB5|----[Built-in LED] (already on board)
     +-------------+
```

1. Place the button on the breadboard.
2. Connect one side of the button to **GND** on the Arduino.
3. Connect the other side of the button to digital pin **2** (which is **PD2** on the ATmega328P).

Since we are using the ATmega328P's internal pull-up resistor, we do not need an external resistor for the button!

---

## The Code — Line by Line

Here is how we read the button and control the LED.

### 1. The Header and DEFINES

```
; ==============================================================================
; Project:       AVR Assembler Lessons
; Author:        Kevin Thomas
; Version:       1.0.0
; Date:          2026-06-28
; Target Device: ATmega328P
; Clock Freq:    16 MHz
; Toolchain:     avr-as, avr-ld, avrdude
; Description:   Lesson 001 - Hello Button World
; ==============================================================================
```

Just like last time, we define our ports and pins to make the code readable.

```
.equ RAMEND, 0x08FF                     ; Last SRAM address (ATmega328P)
.equ SPL,    0x3D                       ; Stack Pointer Low register
.equ SPH,    0x3E                       ; Stack Pointer High register
.equ DDRB,   0x04                       ; Port B Data Direction Register
.equ PORTB,  0x05                       ; Port B Data Register
.equ PB5,    5                          ; Port B Pin 5 (built-in LED)
.equ DDRD,   0x0A                       ; Port D Data Direction Register
.equ PORTD,  0x0B                       ; Port D Data Register
.equ PIND,   0x09                       ; Port D Input Pins Register
.equ PD2,    2                          ; Port D Pin 2 (Button)
```

Notice we have three new registers for Port D:
- **`DDRD`**: Data Direction Register. 1 = Output, 0 = Input.
- **`PORTD`**: Data Register. For inputs, writing a 1 here turns ON the internal pull-up resistor.
- **`PIND`**: Input Pins Register. This is the register we *read* to see if the pin is HIGH or LOW.

### 2. The main Subroutine Setup

```
main:                             
  LDI    R16, lo8(RAMEND)               ; R16 = low byte of last RAM address
  OUT    SPL, R16                       ; Stack Pointer Low = R16
  LDI    R16, hi8(RAMEND)               ; R16 = high byte of last RAM address
  OUT    SPH, R16                       ; Stack Pointer High = R16
```

We set up the stack pointer just like before, so our `RCALL` and `RET` instructions work.

```
  SBI    DDRB, PB5                      ; DDRB bit 5 = 1, PB5 becomes an output
  CBI    DDRD, PD2                      ; DDRD bit 2 = 0, PD2 becomes an input
  SBI    PORTD, PD2                     ; PORTD bit 2 = 1, enable PD2 pull-up
```

- **`SBI DDRB, PB5`**: Makes the LED pin an output.
- **`CBI DDRD, PD2`**: Makes the button pin an input (Clear Bit in I/O Register).
- **`SBI PORTD, PD2`**: Because PD2 is an input, writing a 1 to PORTD turns on the internal pull-up resistor. The pin is now safely pulled HIGH.

### 3. The Main Loop (Making Decisions)

```
.loop:                            
  SBIS   PIND, PD2                      ; Skip next instruction if PD2 is HIGH
  RJMP   .btn_pressed                   ; Jump to btn_pressed if PD2 is LOW
```

Here is where the magic happens. 
- **`SBIS`** stands for **Skip if Bit in I/O Register is Set**. 
- It looks at the button pin (`PIND`, bit `PD2`). 
- If the button is NOT pressed, the pull-up resistor makes the pin HIGH (Set). `SBIS` sees this and **skips** the very next instruction (`RJMP .btn_pressed`).
- If the button IS pressed, the pin connects to GND and goes LOW (Cleared). `SBIS` does not skip, so the CPU executes `RJMP .btn_pressed`.

```
  CBI    PORTB, PB5                     ; PB5 = 0, LED turns OFF
  RJMP   .loop                          ; Jump back to loop
.btn_pressed:                     
  SBI    PORTB, PB5                     ; PB5 = 1, LED turns ON
  RJMP   .loop                          ; Jump back to loop
```
If we skipped the jump (meaning the button is NOT pressed), we turn the LED OFF (`CBI`) and jump back to the start of the loop.

If we did NOT skip the jump (meaning the button IS pressed), we end up here at `.btn_pressed`. We turn the LED ON (`SBI`) and jump back to the start of the loop.

---

## Putting It All Together

```
Power on  ──►  Set up Stack
               Set PB5 as Output
               Set PD2 as Input
               Enable PD2 Pull-Up
                      │
                      ▼
                   .loop: ◄─────────────────────────┐
                      │                             │
               Is PD2 HIGH? (Not Pressed)           │
               /                        \           │
            YES (Skip jump)           NO (Take jump)│
             /                            \         │
       Turn LED OFF                  Turn LED ON    │
            |                              |        │
            └──────────────────────────────┴────────┘
```

---

## Building and Flashing

### Step 1: Assemble

Open a terminal and go to the lesson folder:

```bash
cd Assembler/lessons/001
make
```

### Step 2: Flash

Plug in your Arduino/Elegoo Uno R3 and flash the code:

```bash
make flash
```

Press the button on your breadboard. The built-in LED should light up exactly when you press the button and turn off when you let go!

---

## Challenge Questions

1. What happens if you remove `SBI PORTD, PD2`? Try it and hover your hand near the button without touching it.
2. How would you reverse the logic so the LED is ON when the button is NOT pressed, and OFF when you press it?
3. What is the difference between `PORTD` and `PIND`?
4. What instruction does the opposite of `SBIS`? (Hint: Check the AVR instruction set for "Skip if Bit in I/O Register is Cleared").

---

## Words to Remember

| Term | Meaning |
|------|---------|
| **Pull-up Resistor** | A resistor connecting a pin to 5V to prevent it from floating |
| **Floating Pin** | An input pin not connected to anything, picking up random noise |
| **SBIS** | Skip if Bit in I/O Register is Set (HIGH) |
| **SBIC** | Skip if Bit in I/O Register is Cleared (LOW) |
| **PIN Register** | The register you read to get the actual HIGH/LOW state of an input pin |
| **PORT Register** | The register you write to for setting outputs HIGH/LOW or turning on pull-up resistors |

---

## What Is Next?

You now know how to control the outside world (LEDs) and listen to it (Buttons). In Lesson 002, we will tackle one of the most powerful tools in embedded systems: Serial Communication (UART). You will learn how to make the ATmega328P talk to your computer!
