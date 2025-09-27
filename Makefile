all:
	cargo run

clean:
	cargo clean

re: clean re

.PHONY: all clean re
