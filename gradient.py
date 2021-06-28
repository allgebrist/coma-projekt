import cv2
import numpy as np


def vertical_gradient(image, begin, end):
    """
        Eingabe: - image: Ein RGBA-Bild.
                 - begin: Eine Tupel, die die Anfangsfarbe des Farbwertgradienten darstellt.
                 - end:   Eine Tupel, die die Endfarbe des Farbwertgradienten darstellt.

        Ausgabe: Ein Farbwertgradient mit der gleichen Größe wie 'image'.
    """

    # Leeres Bild mit gleicher Größe von 'image'
    image_gradient = np.ndarray(image.shape, dtype = np.uint8)

    # Umwandlung des Bildes in ein BGR-Bild
    rows, cols = image.shape[0], image.shape[1]
    gradient_b = float(end[0] - begin[0]) / rows
    gradient_g = float(end[1] - begin[1]) / rows
    gradient_r = float(end[2] - begin[2]) / rows

    for i in range(rows):
        for j in range(cols):
            image_gradient[i, j, 0] = begin[0] + i * gradient_b
            image_gradient[i, j, 1] = begin[1] + i * gradient_g
            image_gradient[i, j, 2] = begin[2] + i * gradient_r

    return image_gradient
