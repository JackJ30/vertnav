package main

import "core:strings"
import "core:os"

Field :: struct {
	input_buffer: strings.Builder,
}

field_make :: proc() -> Field {

	field: Field

	field.input_buffer = strings.builder_make()
	wkdir, _ := os.get_working_directory(context.temp_allocator)
	strings.write_string(&field.input_buffer, wkdir)

	return field
}

field_destroy :: proc(field: ^Field) {
	strings.builder_destroy(&field.input_buffer)
}

field_insert :: proc(field: ^Field, r: rune) {
	strings.write_rune(&field.input_buffer, r)
}

field_pop :: proc(field: ^Field) {
	strings.pop_rune(&field.input_buffer)
}

field_get_str :: proc(field: Field) -> string {
	return strings.to_string(field.input_buffer)
}
