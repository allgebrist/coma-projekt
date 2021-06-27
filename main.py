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
        Eingabe:

        Ausgabe: 
    """

    image = Image.open(filename)
    print(image.format, image.size, image.mode)

    b, h = image.size

    image_rgba = image.convert("RGBA")
    image_data = list(image_rgba.getdata())

    m_vector = Main.VecR3(m[0], m[1], m[2])
    frame = Main.ImageFrame(-250, 250, -250, 250, 250)

    snapshot = Main.snapshot_sphere(b, h, image_data, m_vector, r, density, frame, y_axis_select)

    img = Image.new("RGBA", (500, 500))
    img.putdata(snapshot)
    img.save(r'output.png')
    img.show()



def shade_sphere():
    """
        Eingabe:

        Ausgabe: 
    """

    background = np.array(Image.open("Images/plainblack.png"))
    snapshot_rgba = np.array(Image.open("output.png"))

    gradient = vertical_gradient(snapshot_rgba, (255, 255, 255), (0, 0, 0))
    shaded_sphere = cv2.addWeighted(snapshot_rgba, 1.0, gradient, 0.55, 0.0)

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