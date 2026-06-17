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
	Ctrl,
	Shift,
	Alt,
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

	// by default we're giving back the rune
	kp.key = c

	// if the character isn't printable, check and see if it's a NamedKey
	if !unicode.is_print(c) {
		if c == ascii.DEL do kp.key = NamedKey.Delete
		if c == ascii.CR  do kp.key = NamedKey.Return
	}

	// todo(jqj): what to return if it isn't printable or named key?

	return kp, true

	// if true {
	// 	if unicode.is_print(c) do dprintf("%c", c)
	// 	else                   do dprintf("%d", c)
	// 	continue
	// }
}
