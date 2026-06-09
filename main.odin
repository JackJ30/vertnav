package main

import "core:os"
import "core:fmt"
import "core:io"
import "core:strings"
import "core:unicode"

import "core:sys/posix"
import "core:c/libc"

import "ascii"

default_term: posix.termios

uncook :: proc() {
	// get default termios
	posix.tcgetattr(posix.STDIN_FILENO, &default_term)

	// configure and set new termios
	raw := default_term
	raw.c_iflag -= { .IXON, .ICRNL, .BRKINT, .INPCK, .ISTRIP }
	raw.c_oflag -= { .OPOST }
	raw.c_lflag -= { .ECHO, .ICANON, .ISIG, .IEXTEN }
	raw.c_cflag += { .CS8 }
	// raw.c_cc[.VMIN] = 0
	// raw.c_cc[.VTIME] = 1
	posix.tcsetattr(posix.STDIN_FILENO, .TCSAFLUSH, &raw)

	// also open /dev/tty
	open_tty()
}

recook :: proc() {
	// reset to default ermios
	posix.tcsetattr(posix.STDIN_FILENO, .TCSAFLUSH, &default_term)

	// also close /dev/tty
	close_tty()
}

main :: proc() {

	// todo(jqj): error handling for cooking and uncooking
	// prepare the terminal for greatness
	uncook()
	defer recook()

	// main string builder
	sb := strings.builder_make()
	defer strings.builder_destroy(&sb)

	// initial clear
	dprint("\r", ascii.CLEAR_LINE, sep="")

	// main input loop
	for {

		// read input and handle errors and exits
		c, size, err := io.read_rune(os.to_stream(os.stdin))
		if err == .EOF || c == 3 do break
		else if err != .None {
			dprintf("Error: {}\r\n", err)
			break
		}

		// if true {
		// 	if unicode.is_print(c) do dprintf("%c", c)
		// 	else                   do dprintf("%d", c)
		// 	continue
		// }

		if unicode.is_print(c) {
			
			// printable, throw it in the buffer
			strings.write_rune(&sb, c)

		} else {
			
			// non printable, check for keybinds
			if c == ascii.DEL do strings.pop_rune(&sb)
		}

		// display input buffer
		dprint("\r", ascii.CLEAR_LINE, strings.to_string(sb), sep="")

	}
	dprint("\r")

	fmt.println(strings.to_string(sb))
}
