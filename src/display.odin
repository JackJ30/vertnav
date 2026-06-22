package main

import "ascii"
import "core:terminal/ansi"

import "core:os"

display :: proc(field: Field) {

	dprint(ansi.CSI, ansi.ED, sep="")
	
	// print options
	lines_down := 0
	dir := os.dir(field_get_str(field))
	f, oerr := os.open(dir)
	ensure(oerr == nil)
	defer os.close(f)
	it := os.read_directory_iterator_create(f)
	defer os.read_directory_iterator_destroy(&it)
	for info in os.read_directory_iterator(&it) {
		dprint("\r\n", ascii.CLEAR_LINE, info.name, sep="")
		lines_down += 1
	}
	dprint(ansi.CSI, lines_down, ansi.CUU, sep = "")

	// print out input buffer
	// dprint("\r", ascii.CLEAR_LINE, "Find file: ", ansi.CSI + ansi.INVERT + ansi.SGR, field_get_str(field), ansi.CSI + ansi.RESET + ansi.SGR, sep="")
	dprint("\r", ascii.CLEAR_LINE, "Find file: ", field_get_str(field), sep="")
}

display_clean :: proc() {
	// delete all text, move back to start
	dprint(ansi.CSI, ansi.ED, "\r", ascii.CLEAR_LINE, sep="")
}
