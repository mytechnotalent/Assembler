# Lesson 004 - Receiving Data

## This lesson will teach you how to receive data over UART and echo it back using pure AVR assembly.

[CODE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/004/lesson.s)

In the previous lesson, we learned how to transmit a character to the serial monitor. But communication is a two-way street. In this lesson, we are going to write a `uart_receive` subroutine to listen for incoming characters.

Our main loop will now wait for a character to arrive from your keyboard, and then immediately send it right back using our `uart_transmit` subroutine from the last lesson. This creates an "echo" program—everything you type will instantly appear on your screen!

---

## What You Will Learn

- How the UART Receive Complete flag (`RXC0`) works
- How to poll the `UCSR0A` register to wait for incoming data
- How to read incoming bytes from the UART Data Register (`UDR0`)
- How to chain subroutines together to create an interactive loop

---

## The Receive Subroutine

```asm
uart_receive:
  LDS    R17, UCSR0A                    ; Read UCSR0A into R17
  SBRS   R17, RXC0                      ; Skip next instruction if RXC0 is set
  RJMP   uart_receive                   ; Otherwise loop back and check again
  LDS    R16, UDR0                      ; Read UART Data Register into R16
  RET                                   ; Return to caller
```

Just like `uart_transmit` waits for the transmission buffer to be empty (`UDRE0`), our new `uart_receive` subroutine must wait for the reception buffer to be full.

1. **`LDS R17, UCSR0A`**: We load the UART Control and Status Register A into R17.
2. **`SBRS R17, RXC0`**: We check bit 7 (`RXC0`, Receive Complete). If this bit is 1, it means a new character has successfully arrived. We skip the next instruction and proceed to read it.
3. **`RJMP uart_receive`**: If the bit is 0, we loop back to the start and keep waiting.
4. **`LDS R16, UDR0`**: Once the flag is set, we read the incoming byte from the UART Data Register into R16.

## The Main Loop

```asm
main:
  ; ... stack and init setup ...
.loop:
  RCALL  uart_receive                   ; Wait for character, put in R16
  RCALL  uart_transmit                  ; Transmit character in R16
  RJMP   .loop                          ; Infinite loop to echo back data
```

Instead of just halting the program, our main loop is now infinite. We call `uart_receive`, which blocks until you press a key on your computer. When you do, the character is stored in `R16`.

We then immediately call `uart_transmit`, which takes whatever is in `R16` and sends it back to your computer. Then we loop back and do it all over again!
