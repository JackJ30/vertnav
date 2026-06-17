package main

import "core:strings"
import "core:os"

Field :: struct {
	sb: strings.Builder,
}

field_make :: proc() -> Field {

	field: Field

	field.sb = strings.builder_make()
	wkdir, _ := os.get_working_directory(context.temp_allocator)
	strings.write_string(&field.sb, wkdir)

	return field
}

field_destroy :: proc(field: ^Field) {
	strings.builder_destroy(&field.sb)
}

field_insert :: proc(field: ^Field, r: rune) {
	strings.write_rune(&field.sb, r)
}

field_pop :: proc(field: ^Field) {
	strings.pop_rune(&field.sb)
}

field_get_str :: proc(field: Field) -> string {
	return strings.to_string(field.sb)
}
