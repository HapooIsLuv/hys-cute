#![no_std]
#![no_main]

mod arch {
    pub mod x86_64;
}

use crate::arch::x86_64::{tty::Terminal, vga::VgaColors};
use core::arch::asm;

#[unsafe(no_mangle)]
pub extern "C" fn kmain() -> ! {
    let mut terminal = Terminal::new();
    terminal.terminal_write("Hello kernel!");
    terminal.change_terminal_color(VgaColors::RED, VgaColors::WHITE);
    terminal.terminal_write("Sorry! KerPan! Hys-Cute no longer Valid");
    loop {
        unsafe {
            asm!("hlt");
        }
    }
}

use core::fmt::Write;
use core::panic::PanicInfo;

#[panic_handler]
fn handle_panic(_info: &PanicInfo) -> ! {
    loop {}
}
