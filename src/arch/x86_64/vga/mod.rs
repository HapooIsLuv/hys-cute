#[repr(u8)]
#[derive(Clone, Copy)]
pub enum VgaColors {
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

#[derive(Clone, Copy)]
pub struct VgaColor {
    foreground: VgaColors,
    background: VgaColors,
}

#[derive(Clone, Copy)]
pub struct VgaEntry {
    color: VgaColor,
    char: char,
}

impl VgaColor {
    pub fn new(fg: VgaColors, bg: VgaColors) -> Self {
        VgaColor {
            foreground: fg,
            background: bg,
        }
    }
}

impl Into<u8> for VgaColor {
    fn into(self) -> u8 {
        self.foreground as u8 | (self.background as u8) << 4
    }
}

impl Into<u16> for VgaColor {
    fn into(self) -> u16 {
        // since u8 already have a conversion to u16, I'll just do that
        <VgaColor as Into<u8>>::into(self) as u16
    }
}

impl VgaEntry {
    pub fn new(vga_color: VgaColor, char: char) -> Self {
        VgaEntry {
            color: vga_color,
            char,
        }
    }
}

impl Into<u16> for VgaEntry {
    fn into(self) -> u16 {
        self.char as u16 | (<VgaColor as Into<u16>>::into(self.color)) << 8
    }
}
