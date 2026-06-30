# Lesson 003 - Transmitting Data

## This lesson will teach you how to transmit a single character over UART on an ATmega328P using pure AVR assembly.

[CODE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/003/lesson.s)

In the previous lesson, we initialized the UART hardware, establishing a communication link between the ATmega328P and your computer. However, a link isn't very useful unless you actually send data across it! 

In this lesson, we are going to write a `uart_transmit` subroutine. We will send the letter **'H'** exactly once upon startup, and then halt the program in an infinite loop. This will prevent us from flooding the serial monitor with endless data.

---

## What You Will Learn

- How the UART Data Register (`UDR0`) works
- How to check if the transmit buffer is ready using `UDRE0`
- How to use the `SBRS` instruction (Skip if Bit in Register is Set)
- How to write a robust subroutine that waits for hardware readiness

---

## The Hardware: UDR0 and UDRE0

When you want to send data over UART, you can't just shove bytes onto the wire directly. Instead, you drop your byte into a special hardware mailbox called **`UDR0` (USART Data Register)**. 

However, if you drop a byte into `UDR0` while the hardware is still busy transmitting the *previous* byte, you will overwrite the old data and corrupt your transmission!

To prevent this, the ATmega328P provides a flag bit called **`UDRE0` (USART Data Register Empty)** inside the `UCSR0A` status register. 
- If `UDRE0` is **0**, the mailbox is full. Wait!
- If `UDRE0` is **1**, the mailbox is empty. You can safely drop a new byte into `UDR0`.

---

## The Code — Line by Line

### 1. New Registers and DEFINES

We add the definitions for our Data Register and our Empty flag:

```assembly
  .equ UCSR0A, 0xC0                    ; UART Control and Status Register A
  .equ UDR0,   0xC6                    ; UART Data Register
  .equ UDRE0,  5                       ; USART Data Register Empty Bit
```

### 2. The uart_transmit Subroutine

Here is our robust transmit function. It takes one parameter: the character we want to send must be placed in **`R16`** before calling the subroutine.

```assembly
uart_transmit:                    
  LDS    R17, UCSR0A                   ; Read UCSR0A into R17
  SBRS   R17, UDRE0                    ; Skip next instruction if UDRE0 is set
  RJMP   uart_transmit                 ; Otherwise, loop back and check again
  STS    UDR0, R16                     ; Store data to UART Data Register
  RET                                  ; Return to caller
```

**How it works:**
1. **`LDS R17, UCSR0A`**: Because `UCSR0A` is in extended I/O space (address `0xC0`), we must use `LDS` (Load Direct from Data Space) to read its current value into `R17`.
2. **`SBRS R17, UDRE0`**: This is a powerful instruction! "Skip if Bit in Register is Set". It looks at bit 5 (`UDRE0`) of `R17`. If the bit is `1` (buffer is empty), it simply skips the very next instruction.
3. **`RJMP uart_transmit`**: If the bit was `0` (buffer is full), the `SBRS` instruction does *not* skip. We execute this `RJMP` and jump right back to the top of `uart_transmit` to check again. This creates a tight "polling loop" that waits until the hardware is ready.
4. **`STS UDR0, R16`**: Once the buffer is empty, we drop our character from `R16` into `UDR0` using `STS`. The hardware takes over from there!

### 3. The main Subroutine

```assembly
main:                             
  LDI    R16, lo8(RAMEND)              ; R16 = low byte of last RAM address
  OUT    SPL, R16                      ; Stack Pointer Low = R16
  LDI    R16, hi8(RAMEND)              ; R16 = high byte of last RAM address
  OUT    SPH, R16                      ; Stack Pointer High = R16
  RCALL  uart_init                     ; Call UART initialization routine
  LDI    R16, 'H'                      ; Load ASCII character 'H' into R16
  RCALL  uart_transmit                 ; Call transmit subroutine
.loop:                            
  RJMP   .loop                         ; Infinite loop to keep program running
```

We initialize the UART to **9600 baud**. Then, we load the character `'H'` into `R16` (the assembler automatically converts `'H'` to its ASCII integer value `72`). We call `uart_transmit` to send it over the wire, and finally trap the processor in an infinite `.loop`.

---

## Building and Flashing

### Step 1: Open the Serial Monitor
Before you flash, open the Arduino IDE (or any Serial Monitor tool like PuTTY or `screen`), select the correct COM port for your Uno R3, and set the baud rate to **9600**.

### Step 2: Assemble and Flash
Open a terminal and go to the lesson folder:

```bash
cd Assembler/lessons/003
make
make flash
```

If everything works perfectly, you will instantly see an **`H`** pop up in your Serial Monitor! You can press the physical `RESET` button on your Uno R3 to restart the program and see the `H` print again.

---

## Challenge Questions

1. Why do we pass the character in `R16` instead of `R17`? (Hint: Look at which registers are clobbered).
2. What would happen if we deleted the `SBRS` and `RJMP` lines and just immediately ran `STS UDR0, R16`?
3. The assembler converts `'H'` to `72` (or `0x48` in hex). How does your computer know to display an 'H' instead of the number 72?

---

## Words to Remember

| Term | Meaning |
|------|---------|
| **UDR0** | USART Data Register. The "mailbox" for outgoing and incoming serial bytes. |
| **UDRE0** | USART Data Register Empty. A flag that tells us if `UDR0` is ready for new data. |
| **LDS** | Load Direct from Data Space. Reads a value from memory/extended I/O into a register. |
| **SBRS** | Skip if Bit in Register is Set. Skips the next instruction if a specific bit is 1. |
| **ASCII** | American Standard Code for Information Interchange. The standard that maps numbers to letters. |

---

## What Is Next?

We can send a single character, but what if we want to talk back? In **Lesson 004**, we will learn how to read data coming *from* the computer, and we will build a UART Echo program!
