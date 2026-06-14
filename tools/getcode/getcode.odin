package debug

import "core:fmt"
import "core:os"
import "core:io"
import "core:unicode"
import "core:strings"
import "core:terminal"

import "core:sys/posix"
import "core:c/libc"

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

main :: proc()  {

	uncook()
	defer recook()

	for {
		c, size, err := io.read_rune(os.to_stream(os.stdin))
		if err != .None {
			if err != .EOF do fmt.printf("Error: {}\r\n", err)
			break
		}

		if c == 3 do break

		if unicode.is_print(c) do fmt.printf("%c\r\n", c)
		else                   do fmt.printf("%d (%v)\r\n", c, NP(c))
	}
}

NP :: enum rune {
	NUL = rune(0),
	SOH = rune(1),
	STX = rune(2),
	ETX = rune(3),
	EOT = rune(4),
	ENQ = rune(5),
	ACK = rune(6),
	BEL = rune(7),
	BS  = rune(8),
	HT  = rune(9),
	LF  = rune(10),
	VT  = rune(11),
	FF  = rune(12),
	CR  = rune(13),
	SO  = rune(14),
	SI  = rune(15),
	DLE = rune(16),
	DC1 = rune(17),
	DC2 = rune(18),
	DC3 = rune(19),
	DC4 = rune(20),
	NAK = rune(21),
	SYN = rune(22),
	ETB = rune(23),
	CAN = rune(24),
	EM  = rune(25),
	SUB = rune(26),
	ESC = rune(27),
	FS  = rune(28),
	GS  = rune(29),
	RS  = rune(30),
	US  = rune(31),
	DEL = rune(127),
}
