package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:terminal"

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

	// add working directory to builder
	wkdir, _ := os.get_working_directory(context.temp_allocator)
	strings.write_string(&sb, wkdir)

	// main input loop
	loop: for {
		
		// display input buffer
		dprint("\r", ascii.CLEAR_LINE, strings.to_string(sb), sep="")

		// read input keypress
		press := read_press() or_break

		switch key in press.key {
		case rune:
			strings.write_rune(&sb, key)
			
		case NamedKey: 
			#partial switch key {
				case .Delete: strings.pop_rune(&sb)
				case .Return: break loop
			}
		}
	}

	// delete all text, move back to start
	dprint("\r", ascii.CLEAR_LINE, sep="")

	// output the buffer
	fmt.print(strings.to_string(sb))
	if terminal.is_terminal(os.stdout) {
		fmt.print("\r\n")
	}
}
