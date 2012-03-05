GAMEFILE=rapdev.love
CONTENTS=A B C D E F MoonGame LvlUp Menu hardoncollider *.lua
MOONCOMPS=MoonGame/game.lua
MOONGAMES=MoonGame/game.moon

all: package

moonall: moonclean mooncomp all

moonclean:
	rm -f $(MOONCOMPS)

mooncomp:
	moonc $(MOONGAMES)

clean:
	rm -f $(GAMEFILE)

package: clean
	zip -r $(GAMEFILE) $(CONTENTS)
	chmod og+x $(GAMEFILE)

run: package
	love $(GAMEFILE)
