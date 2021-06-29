
struct VecR3
	"""
	Dieser abstrakte Datentyp beschreibt 
	einen Vektor im euklidischen Raum R^3.
	"""
	x::Float64
	y::Float64
	z::Float64
end



struct ImageFrame
	"""
	Wir nutzen hier die Annahmen, dass die Bildebene 
	orthogonal auf der z-Achse steht und  sich 
	der Fokuspunkt im Ursprung (0,0,0) des R^3 befindet.
	"""
	left::Int
	right::Int
	bottom::Int
	top::Int
	depth::Int
end



function equation_solvable(a::Real, b::Real, c::Real)::Bool
	"""
		Eingabe: Drei reelle Zahlen a, b, c, die den Koeffizienten
			 eines Polynoms zweiten Grades ax^2 + bx + c ensprechen.

		Ausgabe: Ein Boolescher Wert: 'false', falls die homogene Gleichung 
			 ax^2 + bx + c = 0 keine reelle Lösung hat, andernfalls 'true'.
	"""
	return ((b^2 - (4 * a * c)) < 0 ? false : true)
end



function mapping(p::VecR3, frame = ImageFrame(-250, 250, -250, 250, 250), y_axis_select = false)::Any
	"""
		Eingabe: - p: 		  Ein Vektor im euklidischen Raum R^3.
			 - frame: 	  Ein ImageFrame, aus dem man die Position der Bildebene im R^3 gewinnen kann.
			 - y_axis_select: Ein Boolescher Wert, der besagt, ob wir die Kugel bzgl. der z- oder y-Achse betrachten wollen.

		Ausgabe: Die abgerundeten Koordinaten des Schnittpunkts von 'p' und der Bildebene 'frame', falls 'p' im Bild der
			 Kamera liegt. Andernfalls wird 'nothing' zurückgegeben.  
	"""
	@assert frame.depth > 0
	@assert frame.left < frame.right
	@assert frame.bottom < frame.top

	if y_axis_select == false
		if p.z >= frame.depth
			# Ist die z-Koordinate von p kleiner als frame.depth,
			# so schneidet der Ortsvektor [0,p] die Bildebene nicht.
			t = frame.depth / p.z
			x = t * p.x
			y = t * p.y

			if (frame.left <= x && x < frame.right) && (frame.bottom <= y && y < frame.top)
				return (floor(Int, x), floor(Int, y))
			end
		end
	end

	if y_axis_select == true
		if p.y >= frame.depth
			# Ist die y-Koordinate von p kleiner als frame.depth,
			# so schneidet der Ortsvektor [0,p] die Bildebene nicht.
			t = frame.depth / p.y
			x = t * p.x
			z = t * p.z

			if (frame.left <= x && x < frame.right) && (frame.bottom <= z && z < frame.top)
				return (floor(Int, x), floor(Int, z))
			end
		end
	end

	return nothing

end



function is_visible(p::VecR3, m::VecR3, r::Real, frame = ImageFrame(-250, 250, -250, 250, 250), y_axis_select = false)::Bool
	"""
		Eingabe: - p: 		  Ein Vektor im euklidischen Raum R^3.
			 - m: 		  Ein Vektor im euklidischen Raum R^3, welcher der Mittelpunkt einer 2-Sphäre darstellt.
			 - r:		  Der Radius der besagten 2-Sphäre.
			 - frame: 	  Ein ImageFrame, aus dem man die Position der Bildebene im R^3 gewinnen kann.
			 - y_axis_select: Ein Boolescher Wert, der besagt, ob wir die Kugel bzgl. der z- oder y-Achse betrachten wollen.

		Ausgabe: Ein Boolescher Wert: 'true', falls 'p' im Bild der Kamera liegt und das Liniensegment zwischen 'p' und dem Schnittpunkt 's'
			 von p und der Bildebene die Sphäre in keinem zweiten Punkt schneidet; 'false', falls 'p' nicht im Bild der Kamera liegt oder falls 
			 'p' im Bild der Kamera liegt und das Liniensegment [s, p] die Sphäre in einem zweiten Punkt schneidet.
	"""

	if mapping(p, frame, y_axis_select) != nothing
		a = (p.x)^2 + (p.y)^2 + (p.z)^2
		b = (-2) * ((p.x * m.x) + (p.y * m.y) + (p.z * m.z))
		c = (m.x)^2 + (m.y)^2 + (m.z)^2 - (r)^2


		if equation_solvable(a, b, c)

			discriminant = b^2 - (4 * a * c)

			if discriminant == 0
				s1 = (-b) / (2 * a)
				s2 = s1
			else 
				s1 = (-b + sqrt(discriminant)) / (2 * a)
				s2 = (-b - sqrt(discriminant)) / (2 * a)
			end

			## Wenn s1 != s2, dann schneidet die Gerade g 
			## die 2-Sphäre S in zwei Punkten

			## s1 soll das Skalar zum betrachteten Punkt sein
			## immer 1, da Richtungsvektor
			if s1 != s2 && abs(s2 - 1) < abs(s1 - 1)
				s1, s2 = s2, s1
			end

			# Wir bestimmen den Skalierungsfaktor t, so dass für
			# den Schnittpunkt p' = mapping(p, frame, y_axis_select)
			# gilt p' = t⋅p.
			if y_axis_select == false
				t = frame.depth / p.z
			else
				t = frame.depth / p.y
			end

			## Zweiter Schnittpunkt darf nicht zwischen Punkt
			## und Bildfläche sein, vergleiche dazu Skalare
			if s1 == s2 || s2 > 1 || s2 < t
				return true
			else
				return false
			end

		end

	end

	return false

end



function parametrization_sphere(theta::Real, phi::Real, m::VecR3, r::Real)::VecR3
	"""
		Eingabe: - theta: Ein Winkel, der im Intervall [0,π] liegen muss.
			 - phi:   Ein Winkel, der im Intervall [0,2π] liegen muss.
			 - m: 	  Ein Vektor im euklidischen Raum R^3, welcher der Mittelpunkt einer 2-Sphäre darstellt.
			 - r:	  Der Radius der besagten 2-Sphäre.

		Ausgabe: Der Wert der in 'Projekt.pdf' beschriebenen Parametrisierungsfunktion 'f' für
			 die Sphäre S, die durch m und r definiert ist, und die Winkel 'theta' und 'phi'.		
	""" 

	return VecR3(m.x + r * sin(theta) * cos(phi), 
		     m.y + r * sin(theta) * sin(phi), 
		     m.z + r * cos(theta))
end



function samples(first_coordinate::Real, second_coordinate::Real, b::Int, h::Int, m::VecR3, r::Real, density::Int)::Any
	"""
		Eingabe: - first_coordinate:  Die erste Koordinate eines Pixels (x).
			 - second_coordinate: Die zweite Koordinate eines Pixels (y oder z)
			 - b: 		      Die Breite des eingelesenen PNG-Bildes.
			 - h: 		      Die Höhe des eingelesenen PNG-Bildes.
			 - m: 		      Ein Vektor im euklidischen Raum R^3, welcher der Mittelpunkt einer 2-Sphäre darstellt.
			 - r: 		      Der Radius der besagten 2-Sphäre.
			 - density: 	      Ein Parameter, der die Zahl der Samples pro Pixel variiert.

		Ausgabe: Eine Liste von VecR3-Objekten von Punkten auf der Sphäre S, die durch m und r definiert ist.
	"""
	sample_list = []

	for k in 1 : density
		# first_coordinate hat x als Defaultwert
		theta = ((first_coordinate + rand()) * pi) / h
		# second_coordinate kann je nach Situation y oder z sein
		phi = ((second_coordinate + rand()) * 2 * pi) / b
		push!(sample_list, parametrization_sphere(theta, phi, m, r))
	end

	return sample_list

end



function snapshot_sphere(b::Int, h::Int, data::AbstractArray, m::VecR3, r::Real, density::Int, frame = ImageFrame(-250, 250, -250, 250, 250), y_axis_select = false)::AbstractArray
	""" 
		Eingabe: - b: 		  Die Breite des eingelesenen PNG-Bildes.
		 	 - h:		  Die Höhe des eingelesenen PNG-Bildes.
			 - data: 	  Eine Liste der Länge b x h von 4-Tupeln der RGBA-Werte der Pixel des besagten PNG-Bildes.
			 - m: 		  Ein Vektor im euklidischen Raum R^3, welcher der Mittelpunkt einer 2-Sphäre darstellt.
			 - r: 		  Der Radius der besagten 2-Sphäre.
			 - density: 	  Ein Parameter, der die Zahl der Samples pro Pixel variiert.
			 - frame: 	  Ein ImageFrame, aus dem man die Position der Bildebene im R^3 gewinnen kann.
			 - y_axis_select: Ein Boolescher Wert, der besagt, ob wir die Kugel bzgl. der z- oder y-Achse betrachten wollen.

		Ausgabe: Eine Liste der Länge frame_height x frame_width von 4-Tupeln der RGBA-Werte der Pixel im Snapshots der zu 'data' 
			 zugehörigen Kugel, wobei frame_height = frame.top - frame.bottom und frame_width = frame.right - frame.left.

	"""

	frame_height = frame.top - frame.bottom
	frame_width = frame.right - frame.left

	# Bildebene 'image' wird hergestellt
	image = []
	for i in 1 : frame_height
		pixel = []
		for j in 1 : frame_width
			push!(pixel, (0, 0, 0, 0))
		end
		push!(image, pixel)
	end


	# Ist select_axis = 'z', so ist first_coordinate = x und second_coordinate = y,
	# andernfalls ist first_coordinate = x und second_coordinate = z
	for first_coordinate in 1 : b
		for second_coordinate in 1 : h
			# Berechnung des zugehörigen Pixels in data
			i = (first_coordinate - 1) * h + second_coordinate
			points = samples(first_coordinate, second_coordinate, b, h, m, r, density)
		
			# Für alle Samples soll nun das Abbild berechnet werden und an der
			# zugehörigen Stelle der Bildebene 'image' eingefügt werden
			for k in 1 : size(points, 1)
				if is_visible(points[k], m, r, frame, y_axis_select)
					intersection = mapping(points[k], frame, y_axis_select)
					if intersection != nothing
						image[intersection[1] - frame.left + 1][intersection[2] - frame.bottom + 1] = data[i]
					end
				end
			end
		end
	end


	image_list = []

	if y_axis_select == false
		for i in 1 : frame_height
			for j in reverse(1 : frame_width)
				push!(image_list, image[i][j])
			end
		end
	end

	if y_axis_select == true
		for j in reverse(1 : frame_width)
			for i in 1 : frame_height
				push!(image_list, image[i][j])
			end
		end
	end

	return image_list

end
