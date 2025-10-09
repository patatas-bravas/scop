all:
	zig build run

clean:
	rm -rf .zig-cache

fclean: clean
	rm -rf zig-out

re: fclean all

.PHONY: all clean fclean re
