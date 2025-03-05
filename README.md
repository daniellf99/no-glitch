# No Glitch
Libretro core debugger written in Zig.

Written in Zig v0.13

## Running
Ensure SDL is installed:
```
sudo apt install libsdl2-dev
```

Running the tool:
```
zig build && ./zig-out/bin/main
```

Running the core with RetroArch:
```
flatpak run org.libretro.RetroArch -L {path-to-so}.so "{path-to-rom}"
```

## TODO
* [GUI] Render text with SDL TTF
* [GUI] Render video
* Organize code into src/ dir
* Load shared libs dynamically (see [dlopen](https://man7.org/linux/man-pages/man3/dlopen.3.html), [dlsym](https://man7.org/linux/man-pages/man3/dlsym.3.html) and [this](https://stackoverflow.com/questions/7626526/load-shared-library-by-path-at-runtime))

## Resources
* http://www.ue.eti.pg.gda.pl/fpgalab/zadania.spartan3/zad_vga_struktura_pliku_bmp_en.html
* https://en.wikipedia.org/wiki/BMP_file_format
* http://www.ece.ualberta.ca/~elliott/ee552/studentAppNotes/2003_w/misc/bmp_file_format/bmp_file_format.htm
* https://learn.microsoft.com/pt-br/windows/win32/gdi/bitmap-header-types
* https://learn.microsoft.com/pt-br/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
* https://www.loc.gov/preservation/digital/formats/fdd/fdd000189.shtml
* https://paulbourke.net/dataformats/bmp/