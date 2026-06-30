# Lesson 002 - Hello Serial World

## This lesson will teach you how to initialize UART serial communication on an ATmega328P using pure AVR assembly.

[CODE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/002/lesson.s)

In the embedded world, it is often critical to have a way for your microcontroller to "talk" to your computer so you can see what it is doing. This is where **UART** (Universal Asynchronous Receiver-Transmitter) comes in. It is one of the oldest, simplest, and most reliable ways to send data back and forth.

In this lesson, we will set up the UART hardware on the ATmega328P. Because initialization alone does not produce any visible output, we will also turn on the built-in LED at the very end to prove our setup ran successfully!

---

## What You Will Learn

- What UART is and how "baud rates" work
- How to write to extended I/O registers using `STS`
- How to calculate and set the Baud Rate Register (`UBRR0`)
- How to configure the Control and Status Registers (`UCSR0A`, `UCSR0B`, `UCSR0C`)

---

## What is UART?

UART is a piece of hardware built into the microcontroller that translates data between parallel (bytes inside the chip) and serial (one bit at a time over a wire). 

Because it is "Asynchronous," there is no clock wire to keep the sender and receiver synchronized. Instead, both sides must agree ahead of time on exactly how fast they will talk. This speed is called the **Baud Rate** (bits per second). We will use a standard, fast baud rate of **9600**.

Both sides must also agree on the **Frame Format**. A standard frame consists of:
- 1 Start bit
- 8 Data bits
- No Parity bit
- 1 Stop bit

---

## The Circuit

You only need your **Arduino/Elegoo Uno R3** and the USB cable connected to your computer.

The USB connection on the Uno board is wired to a secondary chip that converts the ATmega328P's serial pins (TX and RX) into a USB signal your computer can understand. We will just look at the built-in LED (PB5) to verify the code runs.

---

## The Code — Line by Line

### 1. UART Registers and DEFINES

```assembly
; ==============================================================================
; Project:       AVR Assembler Lessons
; Author:        Kevin Thomas
; Version:       1.0.0
; Date:          2026-06-29
; Target Device: ATmega328P
; Clock Freq:    16 MHz
; Toolchain:     avr-as, avr-ld, avrdude
; Description:   Lesson 002 - Hello Serial World
; ==============================================================================
```

Here are the standard definitions, plus our new UART registers:

```assembly
  .equ RAMEND, 0x08FF                  ; Last SRAM address (ATmega328P)
  .equ SPL,    0x3D                    ; Stack Pointer Low register
  .equ SPH,    0x3E                    ; Stack Pointer High register
  .equ DDRB,   0x04                    ; Port B Data Direction Register
  .equ PORTB,  0x05                    ; Port B Data Register
  .equ PB5,    5                       ; Port B Pin 5 (built-in LED)
  .equ UBRR0L, 0xC4                    ; UART Baud Rate Register Low
  .equ UBRR0H, 0xC5                    ; UART Baud Rate Register High
  .equ UCSR0A, 0xC0                    ; UART Control and Status Register A
  .equ UCSR0B, 0xC1                    ; UART Control and Status Register B
  .equ UCSR0C, 0xC2                    ; UART Control and Status Register C
  .equ UDR0,   0xC6                    ; UART Data Register
  .equ TXC0,   6                       ; Transmit Complete Flag Bit
  .equ TXEN0,  3                       ; Transmitter Enable Bit
  .equ RXEN0,  4                       ; Receiver Enable Bit
  .equ UCSZ01, 2                       ; Character Size Bit 1
  .equ UCSZ00, 1                       ; Character Size Bit 0
```

Notice that the UART registers are at addresses like `0xC0` and `0xC4`. These are in **extended I/O space**. The standard `OUT` instruction only works for addresses up to `0x3F`. To write to these higher addresses, we must use the **`STS`** (Store Direct to Data Space) instruction instead.

### 2. The main Subroutine

```assembly
main:                             
  LDI    R16, lo8(RAMEND)              ; R16 = low byte of last RAM address
  OUT    SPL, R16                      ; Stack Pointer Low = R16
  LDI    R16, hi8(RAMEND)              ; R16 = high byte of last RAM address
  OUT    SPH, R16                      ; Stack Pointer High = R16
  RCALL  uart_init                     ; Call UART initialization routine
  SBI    DDRB, PB5                     ; DDRB bit 5 = 1, PB5 becomes an output
  SBI    PORTB, PB5                    ; PB5 = 1, LED turns ON
.loop:                            
  RJMP   .loop                         ; Infinite loop to keep program running
```

We set up the stack, call our new `uart_init` subroutine, and then turn the LED on. The infinite `.loop` ensures the microcontroller just halts there and keeps the LED glowing.

### 3. The uart_init Subroutine

Here is where we actually configure the hardware. 

#### Setting the Baud Rate and Clearing Flags
First, we must tell the hardware how fast to talk by writing to the `UBRR0` (USART Baud Rate Register). We use the standard timing formula provided in the ATmega328P datasheet for Normal Speed Mode (`U2X0 = 0`):
`UBRR0 = (Clock_Freq / (16 * Baud)) - 1`

For a 16 MHz clock and a standard 9600 baud rate:
`UBRR0 = (16,000,000 / (16 * 9600)) - 1 = (16,000,000 / 153,600) - 1 ≈ 104.16 - 1 = 103`
Rounding to the nearest whole number gives us **103**.

At the same time, we clear the Transmit Complete (`TXC0`) flag by writing a `1` to it in `UCSR0A`. This ensures the UART is in a clean state before we transmit.

```assembly
uart_init:                        
  LDI    R16, (1<<TXC0)                ; Clear TXC0, Normal Speed (U2X0=0)
  STS    UCSR0A, R16                   ; Store to Control and Status Reg A
  LDI    R16, 0                        ; UBRR0H = 0
  STS    UBRR0H, R16                   ; Store into upper byte of baud rate
  LDI    R16, 103                      ; UBRR0L = 103 (9600 baud at 16 MHz)
  STS    UBRR0L, R16                   ; Store into lower byte of baud rate
```

Since the baud rate number could theoretically be larger than 255, `UBRR0` is a 16-bit register split into High (`UBRR0H`) and Low (`UBRR0L`). We write 0 to the high byte and 103 to the low byte.

#### Enabling the Transmitter and Receiver
```assembly
  LDI    R16, (1<<TXEN0)|(1<<RXEN0)    ; Enable transmitter and receiver
  STS    UCSR0B, R16                   ; Store to Control and Status Reg B
```
The `UCSR0B` register controls what parts of the UART are turned on. By setting the `TXEN0` and `RXEN0` bits, we wake up both the transmit and receive circuits. The `(1<<BIT)` syntax shifts a `1` into the correct position. The `|` merges them together.

#### Setting the Frame Format
```assembly
  LDI    R16, (1<<UCSZ01)|(1<<UCSZ00)  ; 8 data bits, 1 stop bit, no parity
  STS    UCSR0C, R16                   ; Store to Control and Status Reg C
```
The `UCSR0C` register configures the frame. Setting both `UCSZ01` and `UCSZ00` configures the standard "8 data bits" mode. By default, the stop bit is 1 and parity is disabled, which is exactly what we want.

#### Flushing the Receive Buffer
When the Arduino first boots up, its bootloader (Optiboot) runs before handing control over to our Assembly program. Sometimes, the physical hardware reset process creates electrical noise that the bootloader mistakenly reads as a "garbage" character. 

To prevent this garbage data from interfering with our code, we must rapidly read the UART Data Register (`UDR0`) in a loop until the Receive Complete flag (`RXC0`) is cleared.

```assembly
.flush_rx:                        
  LDS    R16, UCSR0A                   ; Read UCSR0A into R16
  SBRS   R16, 7                        ; Skip next if RXC0 (bit 7) is set
  RJMP   .flush_done                   ; If empty, we are done flushing
  LDS    R16, UDR0                     ; Read UDR0 to flush the buffer
  RJMP   .flush_rx                     ; Loop back to check again
.flush_done:                      
  RET                                  ; Return to caller
```

---


## Building and Flashing

### Step 1: Assemble

Open a terminal and go to the lesson folder:

```bash
cd Assembler/lessons/002
make
```

### Step 2: Flash

Plug in your Arduino/Elegoo Uno R3 and flash the code:

```bash
make flash
```

If everything works perfectly, the program will rapidly configure the UART in the background and then snap the LED ON. 

---

## Challenge Questions

1. Why do we have to use `STS` instead of `OUT` for the UART registers?
2. If our clock frequency was 8 MHz instead of 16 MHz, what value would we put into `UBRR0L` for a 9600 baud rate in Normal Speed Mode?
3. Why do we need a `.flush_rx` loop at the end of the UART initialization?

---

## Words to Remember

| Term | Meaning |
|------|---------|
| **UART** | Universal Asynchronous Receiver-Transmitter |
| **Baud Rate** | The speed of communication in bits per second (e.g. 9600) |
| **Frame Format** | The agreed-upon structure of data (Start, Data, Parity, Stop) |
| **STS** | Store Direct to Data Space. Used for extended I/O registers |
| **UBRR0** | UART Baud Rate Register |
| **UCSR0x** | UART Control and Status Registers (A, B, and C) |

---

## What Is Next?

Now that the UART hardware is initialized and ready to go, we can actually use it! In **Lesson 003**, we will write a subroutine to wait for the transmitter to be ready, and send a single character of data to your computer screen.
