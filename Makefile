INSTALL_DIR = /usr/local/bin

install:
	install -m 755 todo.sh $(INSTALL_DIR)/todo

uninstall:
	rm -f $(INSTALL_DIR)/todo
