package main

import "core:fmt"
import "core:terminal"
import "core:os"

import "ascii"

main :: proc() {

	// todo(jqj): error handling for cooking and uncooking
	// prepare the terminal for greatness
	uncook()
	defer recook()

	// initialize input field
	field := input_field_make()
	defer input_field_destroy(&field)

	// main loop
	loop: for {
		
		// display input buffer
		dprint("\r", ascii.CLEAR_LINE, input_field_get_str(field), sep="")

		// read input keypress and execute bind
		press := read_press() or_break
		switch key in press.key {

		case rune: {

			// key was a rune
			
			if .Ctrl in press.modifiers {

				// C-c: quit
				if key == 'c' do break loop

			} else {

				// no modifiers, write to field
				input_field_insert(&field, key)
			}
		}

		case NamedKey: {

			// key was a "named key"
			
			#partial switch key {
				case .Delete: input_field_pop(&field)
				case .Return: break loop
			}
		}

		}
	}

	// delete all text, move back to start
	dprint("\r", ascii.CLEAR_LINE, sep="")

	// output the buffer
	fmt.print(input_field_get_str(field))
	if terminal.is_terminal(os.stdout) {
		fmt.print("\r\n")
	}
}
