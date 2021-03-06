import cv2
import numpy as np
from PIL import Image

from julia.api import Julia
jl = Julia(compiled_modules = False)
from julia import Main
Main.include("raytracer.jl")

from gradient import vertical_gradient
from overlay_image import overlay_image_alpha



def take_snapshot(m, r, density, filename, y_axis_select = 0):
    """
        Eingabe: - m:             Ein Vektor im euklidischen Raum R^3, welcher der Mittelpunkt einer 2-Sphäre darstellt.
                 - r:             Der Radius der besagten 2-Sphäre.
                 - density:       Ein Parameter, der die Zahl der Samples pro Pixel variiert.
                 - filename:      Der Pfad der Eingangsbilddatei.
                 - y_axis_select: Ein Boolescher Wert, der besagt, ob wir die Kugel bzgl. der z- oder y-Achse betrachten wollen.

        Ausgabe: Das Snapshot der zu 'filename' zugehörigen Kugel wird gezeigt und in eine Bilddatei 'output.png' gespeichert.
    """

    image = Image.open(filename)
    print(image.format, image.size, image.mode)

    b, h = image.size
    b, h = min(b, h), min(b, h)
    image = image.resize((b, h))

    image_rgba = image.convert("RGBA")
    image_data = list(image_rgba.getdata())

    m_vector = Main.VecR3(m[0], m[1], m[2])
    frame = Main.ImageFrame(-250, 250, -250, 250, 250)

    snapshot = Main.snapshot_sphere(b, h, image_data, m_vector, r, density, frame, y_axis_select)

    img = Image.new("RGBA", (500, 500))
    img.putdata(snapshot)
    img.save(r'output.png')
    img.show()



def shade_sphere(filename = "Images/plainblack.png"):
    """
        Eingabe: Der Pfad einer Bilddatei für den Hintergrund.

        Ausgabe: Ein Bild 'shaded_output.jpg', wo das Bild unter 'filename' im Hintergrund und das Snapshot 'output.png' 
                 der Kugel nach dem (durch einen linearen Farbwertgradienten erzeugten) Shading im Vordergrund steht.
    """

    # Einlesen von Hintergrund und Vordergrund (Snapshot in 'output.png')
    background = np.array(Image.open(filename))
    snapshot_rgba = np.array(Image.open("output.png"))

    # Wir erstellen einen schwarz/weiß Farbwertgradienten und schattieren das Snapshot damit
    gradient = vertical_gradient(background, (255, 255, 255), (0, 0, 0))
    shaded_sphere = cv2.addWeighted(snapshot_rgba, 1.0, gradient, 0.55, 0.0)

    # Wir kombinieren Hintergrund und Vordergrund (shattiertes Snapshot) mithilfe der 'overlay_image_alpha' Funktion 
    # und speichern das Ergebnis in ein Bild 'image_blend', welches dann unter 'shaded_output.jpg' exportiert wird 
    alpha_mask = shaded_sphere[:, :, 3] / 255.0
    snapshot = shaded_sphere[:, :, :3]
    image_blend = background[:, :, :3].copy()
    overlay_image_alpha(image_blend, snapshot, 0, 0, alpha_mask)

    Image.fromarray(image_blend).save("shaded_output.jpg")



# Beispielaufrufe:
#
# take_snapshot((0, 500, 0), 200, 50, "Images/checker.png", 1)
# shade_sphere()
#
# take_snapshot((0, 0, 500), 200, 50, "Images/checker.png", 0)
# shade_sphere()
#
# take_snapshot((0, 500, 0), 200, 50, "Images/stripessmall.png", 1)
# shade_sphere()
#
#
