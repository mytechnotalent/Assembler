# Lesson 005 - Transmitting Strings

## This lesson will teach you how to transmit a full string of text over UART by reading data from Program Memory (Flash).

[CODE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/005/lesson.s)

In our previous lessons, we transmitted and received single characters. But what if we want to print an entire sentence, like "Hello Serial World!"? 

To do this, we need to store our string in memory, and then write a subroutine that iterates over each character in the string, sending them one by one until it reaches the end.

In AVR microcontrollers like the ATmega328P, code and data are stored in separate memory spaces (Harvard Architecture). Our program code lives in **Flash Memory** (Program Memory). Since our string is a constant, we can store it directly in Flash alongside our code and read it using the `LPM` instruction.

---

## What You Will Learn

- How to declare null-terminated strings using `.asciz`
- How to use the 16-bit **Z Pointer Register** (`R30:R31`)
- How to read bytes from Flash Memory using the `LPM` (Load Program Memory) instruction
- How to create a looping subroutine to print a string

---

## Storing Strings in Flash

```asm
my_string:
  .asciz "Hello Serial World!\r\n"
```

The `.asciz` directive tells the assembler to store the given characters in memory, and automatically append a "null terminator" (a byte with the value `0`) at the very end. This `0` acts as a stop sign, telling our printing loop when it has reached the end of the string.

## Pointers and the Z Register

Because Flash memory addresses can be larger than 8 bits (up to 16 bits on the ATmega328P), we need a 16-bit register to hold the memory address of our string. 

AVR provides three special 16-bit pointer registers by combining pairs of 8-bit registers: `X` (R26:R27), `Y` (R28:R29), and `Z` (R30:R31). 

Only the **Z Register** can be used to read from Program Memory (Flash).

```asm
  LDI    R30, lo8(my_string)            ; Load low byte of string addr to Z
  LDI    R31, hi8(my_string)            ; Load high byte of string addr to Z
```

Here, we split the 16-bit address of `my_string` into its high and low bytes, and load them into `R31` and `R30` respectively.

## The Print Subroutine

```asm
uart_print_string:
  LPM    R16, Z+                        ; Load byte from Program Memory, inc Z
  CPI    R16, 0                         ; Compare loaded byte with 0 (null)
  BREQ   .print_done                    ; If zero, we reached end of string
  RCALL  uart_transmit                  ; Transmit the character in R16
  RJMP   uart_print_string              ; Loop back for the next character
.print_done:
  RET                                   ; Return to caller
```

1. **`LPM R16, Z+`**: This is the magic instruction. It stands for **Load Program Memory**. It takes the address currently stored in the Z register, fetches the byte at that address in Flash, puts it into `R16`, and then automatically increments Z to point to the next character.
2. **`CPI R16, 0`**: We compare the loaded character against `0` (the null terminator).
3. **`BREQ .print_done`**: Branch if Equal. If the character *was* `0`, we jump to `.print_done` and return.
4. **`RCALL uart_transmit`**: If it wasn't `0`, we transmit the character.
5. **`RJMP uart_print_string`**: We loop back to the top to grab the next character!
