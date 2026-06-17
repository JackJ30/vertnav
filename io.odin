package main

import "core:fmt"
import "core:os"

tty: ^os.File

open_tty :: proc() {
	err: os.Error
	tty, err = os.open("/dev/tty", { .Write })
	if err != nil do panic("/dev/tty failed to open")
}

close_tty :: proc() {
	err := os.close(tty)
	if err != nil do panic("/dev/tty failed to close")
}

/* dprint functions: writes to the screen output (dev tty) for drawing TUI */

dprintf :: proc(format: string, args: ..any, flush: bool = true) -> int {
    return fmt.fprintf(tty, format, ..args, flush=flush) 
}
dprint :: proc(args: ..any, sep: string = " ", flush: bool = true) -> int {
    return fmt.fprint(tty, ..args, sep=sep, flush=flush) 
}
