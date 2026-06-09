package main

import "core:fmt"
import "core:os"
import "core:io"
import "core:strings"
import "core:unicode"

import "core:sys/posix"
import "core:c/libc"

import "util"

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
}

recook :: proc() {
	// reset to default ermios
	posix.tcsetattr(posix.STDIN_FILENO, .TCSAFLUSH, &default_term)
}

main :: proc() {

	// todo(jqj): error handling for cooking and uncooking
	// prepare the terminal for greatness
	uncook()
	defer recook()

	// main string builder
	sb := strings.builder_make()
	defer strings.builder_destroy(&sb)

	// main input loop
	for {

		// read input and handle errors and exits
		c, size, err := io.read_rune(os.to_stream(os.stdin))
		if err == .EOF || c == 3 do break
		else if err != .None {
			fmt.printf("Error: {}\r\n", err)
			break
		}

		// if true {
		// 	if unicode.is_print(c) do fmt.printf("%c", c)
		// 	else                   do fmt.printf("%d", c)
		// 	continue
		// }

		if unicode.is_print(c) {
			
			// printable, throw it in the buffer
			strings.write_rune(&sb, c)

		} else {
			
			// non printable, check for keybinds
			if c == util.DEL do strings.pop_rune(&sb)
		}

		// display input buffer
		fmt.print("\r", util.CLEAR_LINE, strings.to_string(sb), sep="")

	}
	fmt.print("\r");	
}
