qw: 	main.vala result.vala
	valac -o $@ $^ --pkg gio-2.0 --pkg json-glib-1.0 --pkg libsoup-2.4

