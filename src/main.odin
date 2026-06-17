package main

import "core:fmt"
import "core:terminal"
import "core:os"

main :: proc() {

	// todo(jqj): error handling for cooking and uncooking
	// prepare the terminal for greatness
	uncook()
	defer recook()

	// initialize input field
	field := field_make()
	defer field_destroy(&field)

	// main loop
	loop: for {
		
		// display
		display(field)

		// read input keypress and execute bind
		press := read_press() or_break
		switch key in press.key {

		case rune: {

			// key was a rune
			
			if .Ctrl in press.modifiers {

				// Ctrl-rune keybinds
				if key == 'c' do break loop

			} else {

				// just a rune, insert to field
				field_insert(&field, key)
			}
		}

		case NamedKey: {

			// key was a "named key"
			
			#partial switch key {
				case .Delete: field_pop(&field)
				case .Return: break loop
			}
		}

		}
	}

	display_clean()

	// output the buffer
	fmt.print(field_get_str(field))
	if terminal.is_terminal(os.stdout) {
		fmt.print("\r\n")
	}
}
