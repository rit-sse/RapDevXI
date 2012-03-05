GAMEFILE=rapdev.love
CONTENTS=A B C D E F LvlUp Menu hardoncollider *.lua

all: package

clean:
	rm -f $(GAMEFILE)

package: clean
	zip -r $(GAMEFILE) $(CONTENTS)
	chmod 755 $(GAMEFILE)

run:
	love .
