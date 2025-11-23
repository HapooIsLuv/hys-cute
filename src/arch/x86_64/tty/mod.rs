use crate::arch::x86_64::vga::{VgaColor, vga_entry, vga_entry_color};

const TTY_WIDTH: usize = 80;
const TTY_HEIGHT: usize = 25;
const VGA_MEM: *mut u16 = 0xB800 as *mut u16;

struct Terminal {
    terminal_row: usize,    // Height
    terminal_column: usize, // Width
    terminal_color: u8,
    terminal_buf: *mut u16, // Bare in mind that this is not a reference but a ptr
}

impl Terminal {
    /// initializes the terminal.
    /// As a part of initialization, it sets all the VGA entrys into terminal color.
    /// This is function does include unsafe but the function gives you a safe abstraction
    fn new() -> Self {
        let terminal_color = vga_entry_color(VgaColor::WHITE, VgaColor::BLACK);
        for y in 0..TTY_HEIGHT {
            for x in 0..TTY_WIDTH {
                let index: usize = y * TTY_WIDTH + x;
                unsafe {
                    *VGA_MEM.add(index) = vga_entry(' ', terminal_color);
                } // this is unsafe NOOO
            }
        }
        Terminal {
            terminal_row: 0,
            terminal_column: 0,
            terminal_color,
            terminal_buf: VGA_MEM,
        }
    }

    fn put_entry_at(character: char, color: u8, x: usize, y: usize) {
        let index: usize = y * TTY_WIDTH + x;
        unsafe { *VGA_MEM.add(index) = vga_entry(character, color) }
    }

    fn put_char(&mut self, char: char) {
        Terminal::put_entry_at(
            char,
            self.terminal_color,
            self.terminal_column,
            self.terminal_row,
        );
        if self.terminal_column == TTY_WIDTH {
            self.terminal_column = 0;
            if self.terminal_row == TTY_HEIGHT {
                self.terminal_row = 0;
            } else {
                self.terminal_row += 1;
            }
        } else {
            self.terminal_column += 1;
        }
    }
}
