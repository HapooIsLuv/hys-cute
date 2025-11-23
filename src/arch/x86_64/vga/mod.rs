#[repr(u8)]
pub enum VgaColor {
    BLACK = 0,
    BLUE = 1,
    GREEN = 2,
    CYAN = 3,
    RED = 4,
    MAGENTA = 5,
    BROWN = 6,
    LIGHTGRAY = 7,
    DARKGRAY = 8,
    LIGHTBLUE = 9,
    LIGHTGREEN = 10,
    LIGHTCYAN = 11,
    LIGHTRED = 12,
    LIGHTMAGENTA = 13,
    LIGHTBROWN = 14,
    WHITE = 15,
}

pub const fn vga_entry_color(fg: VgaColor, bg: VgaColor) -> u8 {
    fg as u8 | (bg as u8) << 4
}

pub const fn vga_entry(character: char, color: u8) -> u16 {
    character as u16 | (color as u16) << 8
}
