package main

import "ascii"
import "core:terminal/ansi"

display :: proc(field: Field) {
	// print out input buffer
	// dprint("\r", ascii.CLEAR_LINE, "Find file: ", ansi.CSI + ansi.INVERT + ansi.SGR, field_get_str(field), ansi.CSI + ansi.RESET + ansi.SGR, sep="")
	dprint("\r", ascii.CLEAR_LINE, "Find file: ", field_get_str(field), sep="")
}

display_clean :: proc() {
	// delete all text, move back to start
	dprint("\r", ascii.CLEAR_LINE, sep="")
}
