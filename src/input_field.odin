package main

import "core:strings"
import "core:os"

InputField :: struct {
	sb: strings.Builder,
}

input_field_make :: proc() -> InputField {

	field: InputField

	field.sb = strings.builder_make()
	wkdir, _ := os.get_working_directory(context.temp_allocator)
	strings.write_string(&field.sb, wkdir)

	return field
}

input_field_destroy :: proc(field: ^InputField) {
	strings.builder_destroy(&field.sb)
}

input_field_insert :: proc(field: ^InputField, r: rune) {
	strings.write_rune(&field.sb, r)
}

input_field_pop :: proc(field: ^InputField) {
	strings.pop_rune(&field.sb)
}

input_field_get_str :: proc(field: InputField) -> string {
	return strings.to_string(field.sb)
}
