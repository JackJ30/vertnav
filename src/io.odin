package main

import "core:fmt"
import "core:os"
import "core:io"
import "core:unicode"

import "ascii"

/* dprint functions: writes to the screen output (dev tty) for drawing TUI */
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

dprintf :: proc(format: string, args: ..any, flush: bool = true) -> int {
    return fmt.fprintf(tty, format, ..args, flush=flush) 
}
dprint :: proc(args: ..any, sep: string = " ", flush: bool = true) -> int {
    return fmt.fprint(tty, ..args, sep=sep, flush=flush) 
}

/* get key */

Modifier :: enum {
	Shift,
	Alt,
	Ctrl,
}
ModifierSet :: bit_set[Modifier]

NamedKey :: enum {
	Return,
	Delete,
	Tab,
	Left,
	Right,
	Up,
	Down
}

KeyPress :: struct {
	key: union {
		rune,
		NamedKey,
	},
	modifiers: ModifierSet
}

read_press :: proc() -> (KeyPress, bool) {

	kp: KeyPress

	// read in character from stdin
	c, size, err := io.read_rune(os.to_stream(os.stdin))
	if err != .None {
		if err != .EOF do dprintf("Error: {}\r\n", err)
		return kp, false
	}

	// there is a loop so that these parsing can be reused when we handle weird
	// unicode things
	// todo(jqj): handle weird unicode things
	for {

		// check for single byte named keys
		if c == ascii.CR  { kp.key = NamedKey.Return; break }
		if c == ascii.DEL { kp.key = NamedKey.Delete; break }
		if c == ascii.HT  { kp.key = NamedKey.Tab   ; break }

		// check for CTRL+ASCII
		if c >= 1 && c <= 26 {
			kp.key = c + 96
			kp.modifiers += { .Ctrl }
			break
		}

		// if it's printable 
		if unicode.is_print(c) {
			kp.key = c
			break
		}

		// otherwise no key
		kp.key = nil
		break
	}


	return kp, true
}
