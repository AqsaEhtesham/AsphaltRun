# Car Racing Game (Asphalt Run)

> An immersive 16-bit real-mode x86 assembly racing game designed for DOSBox featuring graphics, sound effects, custom timer ISR, and obstacle collision mechanics.

---

## 📖 Introduction
**Asphalt Run** is a retro 16-bit arcade racing game written entirely in x86 Assembly language (Intel syntax). The player controls a car moving along a three-lane scrolling highway, avoiding oncoming obstacles (enemy cars) and collecting coins to increase their score. It showcases real-time hardware interaction, custom interrupt service routines (ISRs) for timer and sound/music, and double-buffered text-mode rendering techniques.

---

## ✨ Key Features
- **Smooth Text-Mode Graphics**: Uses the BIOS Mode 3 (80x25 16-color text-mode) and the `B800h` video memory segment to render the UI, road, trees, obstacles, and the player's car.
- **Interrupt-Driven Game Mechanics**: Uses a custom Timer ISR (Interrupt 0x08) to manage game timing, speed up scrolling, and handle duration ticks.
- **Dynamic Obstacle Generation**: Randomly generates enemy cars in one of the three lanes, with cooldowns to maintain gameplay balance.
- **Score & Bonus System**: Displays a real-time HUD with the current score and a countdown timer. Coins collectable on the road award bonus points (+10).
- **Retro Music & Sound Effects**: Custom speaker-based music engine (`play_tone`/`stop_music`/`update_music`) using the PIT (Programmable Interval Timer) channel 2.
- **Interactive Start & Game Over Screens**: Beautifully styled ASCII intro, loading progress bar, and Game Over screen with options to restart (`y/Y`) or exit (`n/N`).
- **Memory-Safe Play Loop**: Implements safe execution bounds with a stack-safe jump routine upon restarts.

---

## 🛠️ Technologies Used
- **Language**: x86 16-bit Real Mode Assembly (NASM syntax).
- **Assembler**: [NASM (Netwide Assembler)](https://www.nasm.us/) (v2.16.01 or later).
- **Emulator**: [DOSBox](https://www.dosbox.com/) (v0.74-3 or later) or DOSBoxPortable.
- **Platform**: Windows / DOS.

---

## 📂 Project Structure Overview
```text
Car Racing Game/
├── CarRacing.asm          # Main 16-bit assembly source code
└── README.md              # Project documentation and setup guide
```

---

## 🚀 Setup Guide & Installation

Follow these step-by-step instructions to set up the project locally on your machine.

### 📋 Prerequisites
Ensure you have the following installed or available on your system:
1. **NASM (Netwide Assembler)**: Needed to compile the `.asm` code into a flat binary `.com` executable.
2. **DOSBox**: An x86 emulator with DOS to run real-mode x86 code on modern operating systems.

> [!NOTE]
> On the user's workspace, these tools are available in the folder `C:\Users\DELL E5590\Downloads\Assembly Programming Tools\assemblytools\`.

---

### 💻 Local Installation & Compilation
1. **Clone/Copy the Project Directory**:
   Ensure you have the project directory `Car Racing Game` with the source file [CarRacing.asm](file:///C:/Users/DELL%20E5590/.gemini/antigravity-ide/scratch/Car%20Racing%20Game/CarRacing.asm).

2. **Assemble the Source Code**:
   Open a terminal (PowerShell or Command Prompt) and compile the `.asm` file using NASM:
   ```cmd
   nasm -f bin -o p.com CarRacing.asm
   ```
   *Note: This generates a flat DOS executable file named `p.com`.*

3. **Configure DOSBox**:
   Create a directory to mount (e.g., `C:\asm-run`), and move your compiled `p.com` executable into it.

---

### 🎮 Running the Project

To run the game, launch DOSBox with the following commands executed inside the emulator console:
```text
mount c C:\asm-run
c:
p.com
```

Alternatively, you can automate this using a batch file (`Run_Game.bat`):
```batch
@echo off
"path\to\nasm.exe" -f bin -o C:\asm-run\p.com "path\to\CarRacing.asm"
"path\to\DOSBox.exe" -c "mount c C:\asm-run" -c "c:" -c "p.com"
```



## 🔮 Future Improvements
- **Obstacle Speed Scaling**: Increase the speed of oncoming cars as the score goes up.
- **Power-Ups**: Implement temporary shields or time-extension tokens.
- **Enhanced Soundtracks**: Support multiple retro melodies using polyphonic channel emulation or AdLib/SoundBlaster synthesis.
- **High Scores Persistence**: Save and load the highest scores to/from a DOS file.


## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
