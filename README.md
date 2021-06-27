# Projekt - Computerorientierte Mathematik II

In diesem Projekt stellen wir einen julia-nativen Ray-Tracer vor, welcher mithilfe des in `Projekt.pdf` eingeführten vereinfachten Kameramodells implementiert wurde. Dabei wird eine Textur in Form eines PNG-Bildes auf eine Kugel im Raum projiziert und von dieser Kugel mit Textur „ein Foto geschossen“, welches wiederum als PNG ausgegeben wird. Das Einlesen wird hier mittels Python durchgeführt, während die Bildverarbeitung in Julia stattfindet. 

Um die Funktionen in der Datei `main.py` nutzen zu können, kann dieser Ordner heruntergeladen und das Skript im Terminal mittels `python -i main.py` ausgeführt werden. Die hierfür notwendigen Imports sind `cv2`, `numpy`, `julia` und `julia.api`.

---

### Beispielaufrufe:

Snapshots der Texturen `Images/grid.png` und `Images/sun.png` mit Shading und einfachem Hintergrund: 

```python
  take_snapshot((0, 500, 0), 200, 50, "Images/grid.png", 1)
  shade_sphere()
  
  take_snapshot((0, 500, 0), 200, 50, "Images/sun.png", 1)
  shade_sphere()
```


Texture: Images/grid.png          |  Texture: Images/sun.png
:-------------------------:|:-------------------------:
![](https://github.com/allgebrist/coma-projekt/blob/main/Examples/shaded_grid.jpg)  |  ![](https://github.com/allgebrist/coma-projekt/blob/main/Examples/shaded_sun.jpg )

---

### Entwickelt von:

- Jonas Lorenz
- Aleksandra Soloveva
- Allan Zea
