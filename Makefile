OUTPUT = game-of-life
SOURCES = *.vala
OPTIONS = --pkg gtk+-3.0 --pkg posix

all: $(OUTPUT) run

$(OUTPUT): $(SOURCES)
	valac -o $(OUTPUT) $(OPTIONS) $(SOURCES)

ccode: $(SOURCES)
	valac -C $(OPTIONS) $(SOURCES)

clean:
	rm $(OUTPUT)

run:
	./$(OUTPUT)
