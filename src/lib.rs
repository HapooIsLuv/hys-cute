#![no_std]
#![no_main]

mod arch {
    mod x86_64;
}

use core::arch::asm;

#[unsafe(no_mangle)]
pub extern "C" fn kmain() -> ! {
    loop {
        unsafe {
            asm!("hlt");
        }
    }
}

use core::panic::PanicInfo;

#[panic_handler]
fn handle_panic(_info: &PanicInfo) -> ! {
    loop {}
}
