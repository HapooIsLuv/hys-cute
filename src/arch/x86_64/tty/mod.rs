use crate::arch::x86_64::vga::{VgaColor, vga_entry, vga_entry_color};
const TTY_WIDTH: usize = 80;
const TTY_HEIGHT: usize = 25;
const VGA_MEM: *mut u16 = 0xB8000 as *mut u16;

pub struct Terminal {
    terminal_row: usize,    // Height
    terminal_column: usize, // Width
    terminal_color: u8,
}

impl Terminal {
    /// initializes the terminal.
    /// As a part of initialization, it sets all the VGA entrys into terminal color.
    /// This is function does include unsafe but the function gives you a safe abstraction
    pub fn new() -> Self {
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
        }
    }

    fn _put_entry_at(character: char, color: u8, x: usize, y: usize) {
        let index: usize = y * TTY_WIDTH + x;
        unsafe { *VGA_MEM.add(index) = vga_entry(character, color) }
    }

    fn _put_char(&mut self, char: char) {
        Terminal::_put_entry_at(
            char,
            self.terminal_color,
            self.terminal_column,
            self.terminal_row,
        );

        match self.terminal_column + 1 {
            column if column == TTY_WIDTH => {
                self.terminal_column = 0;
                match self.terminal_row + 1 {
                    row if row == TTY_HEIGHT => self.terminal_row = 0,
                    row => self.terminal_row = row,
                }
            }
            column => self.terminal_column = column,
        }
    }

    /// For future reference, this function is exposed as a public method just for now,
    /// one must prefer the println! macro over at the future when the macro is implemented.
    pub fn terminal_write(&mut self, string: &str) {
        for char in string.chars() {
            self._put_char(char);
        }
    }
}
