![image](https://github.com/mytechnotalent/Assembler/blob/main/Assembler.png?raw=true)

## FREE Reverse Engineering Self-Study Course [HERE](https://github.com/mytechnotalent/Reverse-Engineering-Tutorial)

<br>

# Assembler
Assembly Language on an AVR Microcontroller.

<br>

## Why?

In the fascinating world of Reverse Engineering, I have discovered a profound and empowering truth. To truly build, innovate, and secure our future, we must clearly see our foundation. Right now, Data and Computer Science are standing at a critical crossroads. As AI accelerates our capabilities, it also layers immense abstraction over the foundational truths of our digital world. We are at risk of trading the empowering clarity of true comprehension for comfortable convenience, wrapping our infrastructure in black boxes that distance us from the core.

But technology is not magic. It is beautiful, orchestrated logic. When we push the boundaries of innovation or need to uncover a vulnerability hidden deep within a compiled binary, an AI wrapper alone will not be enough. Our greatest strength and our ultimate security lie in understanding the ground truth of Data and Computer Science.

This is exactly why this 1000 lesson series on AVR Assembly is far more than an educational exercise. It is a vibrant celebration of the soul of STEM. It is a deliberate, empowering choice to look past the abstraction and become an Assembler. To be an Assembler is to serve as the vital bridge between human intent and physical reality. It means cultivating the patience and discipline to piece together complex systems from their most fundamental, atomic units. An Assembler does not just consume high-level logic or guess at how a system functions. An Assembler orchestrates the raw physics of the hardware itself, uniting brilliant software with the uncompromising reality of the machine.

Together, we will step beyond the bloated compilers and APIs to reconnect with the bare metal. By mastering the precise language of registers, memory addresses, and raw clock cycles on a microscopic chip, we reclaim complete ownership of our craft. We illuminate the silicon and transform mystery into mastery.

If the next generation of developers relies solely on generative models and abstracted code, they will become mere passengers on the journey of technological progress. This series is about forging visionary and resilient architects. It is about cultivating the brilliant, inquisitive mindset of Reverse Engineering so anyone can look into a compiled binary, effortlessly decode its secrets, and confidently command its electrical heartbeat. We owe it to the future of Data and Computer Science to ensure that human engineers remain the inspired, unquestioned masters of the machine.

This will take a few years to develop by hand, but building a lasting legacy of true understanding is a journey worth every single moment.

<br>

## Hardware Option
If you are following along with these tutorials, we recommend the [ELEGOO UNO Project Super Starter Kit](https://www.amazon.com/ELEGOO-Project-Tutorial-Controller-Projects/dp/B01D8KOZF4) as a great starting point for your hardware.

<br>

## Toolchain Installation

### Linux (x86_64)
```bash
sudo apt update
sudo apt install binutils-avr avrdude
```

### macOS (Apple Silicon)
```bash
brew update
brew install avr-binutils avrdude
```
The tools will be installed to `/opt/homebrew/opt/avr-binutils/bin/`. Add it to your `PATH`:
```bash
export PATH="/opt/homebrew/opt/avr-binutils/bin:$PATH"
```

### macOS (Intel)
```bash
brew update
brew install avr-binutils avrdude
```
The tools will be installed to `/usr/local/opt/avr-binutils/bin/`. Add it to your `PATH`:
```bash
export PATH="/usr/local/opt/avr-binutils/bin:$PATH"
```

### Windows
#### Option 1 — MSYS2 (Recommended)
1. Install [MSYS2](https://www.msys2.org/)
2. Open the **UCRT64** terminal and run:
```bash
pacman -Syu
pacman -S mingw-w64-ucrt-x86_64-avr-binutils avrdude
```
Add `C:\msys64\ucrt64\bin` to your system `PATH`.

#### Option 2 — Microchip Toolchain
1. Download the **AVR Toolchain for Windows** from [Microchip](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio)
2. Download [AVRDUDE](https://github.com/avrdudes/avrdude/releases)
3. Add both `bin/` directories to your system `PATH`.

<br>

## Tools Provided
| Tool          | Description                          |
|---------------|--------------------------------------|
| `avr-as`      | Assembler                            |
| `avr-ld`      | Linker                               |
| `avr-objcopy` | Object file copy / format conversion |
| `avr-objdump` | Object file disassembler             |
| `avr-size`    | ELF section size reporter            |
| `avrdude`     | Microcontroller programmer           |

<br>

## Lesson 000: Hello Blinky World
This lesson will teach you how to make an LED blink on an ATmega328P using pure AVR assembly, from writing the code to uploading it onto the microcontroller.

-> Click [HERE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/000/lesson.md) to read the lesson and see the code.

## Lesson 001: Hello Button World
This lesson will teach you how to read a button press to turn on an LED on an ATmega328P using pure AVR assembly.

-> Click [HERE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/001/lesson.md) to read the lesson and see the code.

## Lesson 002: Hello Serial World
This lesson will teach you how to initialize UART serial communication on an ATmega328P using pure AVR assembly.

-> Click [HERE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/002/lesson.md) to read the lesson and see the code.

## Lesson 003: Transmitting Data
This lesson will teach you how to transmit a single character over UART on an ATmega328P using pure AVR assembly.

-> Click [HERE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/003/lesson.md) to read the lesson and see the code.

## Lesson 004: Receiving Data
This lesson will teach you how to receive data over UART and echo it back using pure AVR assembly.

-> Click [HERE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/004/lesson.md) to read the lesson and see the code.

## Lesson 005: Transmitting Strings
This lesson will teach you how to transmit a full string of text over UART by reading data from Program Memory (Flash).

-> Click [HERE](https://github.com/mytechnotalent/Assembler/blob/main/lessons/005/lesson.md) to read the lesson and see the code.

### IN DEVELOPMENT 994 MORE LESSONS TO COME

<br>

See [LICENSE](https://github.com/mytechnotalent/Assembler/blob/main/LICENSE).
