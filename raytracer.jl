
struct VecR3
	x::Real
	y::Real
	z::Real
end



struct ImageFrame
	"""
	Wir nutzen hier die Annahmen, dass die Bildebene 
	orthogonal auf der z-Achse steht und  sich 
	der Fokuspunkt im Ursprung (0,0,0) des R^3 befindet
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
		Eingabe: - p: 
			 - frame: 
			 - y_axis_select: 

		Ausgabe: 
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
		Eingabe: - p: 
			 - m: 		
			 - r:	
			 - frame:
			 - y_axis_select: 

		Ausgabe: 
	"""

	if mapping(p, frame, y_axis_select) != nothing
		a = (p.x)^2 + (p.y)^2 + (p.z)^2
		b = (-2) * ((p.x * m.x) + (p.y * m.y) + (p.z * m.z))
		c = (m.x)^2 + (m.y)^2 + (m.z)^2 - (r)^2


		if equation_solvable(a, b, c)
			
			## numerisch idealisiert, da es sein kann, dass
			## die Diskriminante minimal kleiner als 0 ist
			## obwohl Punkt auf Sphäre
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
			if y_axis_select == false

				if s1 != s2
					if s1 != 1
						s1, s2 = s2, s1
					end
				end

				t = frame.depth / p.z

				if s1 == s2 || s2 > 1 || s2 < t
					return true
				else
					return false
				end
			end

			if y_axis_select == true

				if s1 != s2 && abs(s2 - 1) < abs(s1 - 1)
					s1, s2 = s2, s1
				end				

				t = frame.depth / p.y

				if s1 == s2 || s2 > 1 || s2 < t
					return true
				else
					return false
				end
			end
		end

	end

	return false

end



function parametrization_sphere(theta::Real, phi::Real, m::VecR3, r::Real)::VecR3
	"""
		Eingabe: - theta: Ein Winkel, der im Intervall [0,π] liegen muss.
			 - phi:   Ein Winkel, der im Intervall [0,2π] liegen muss.
			 - m: 		
			 - r:	

		Ausgabe: 	
	""" 

	return VecR3(m.x + r * sin(theta) * cos(phi), 
		     m.y + r * sin(theta) * sin(phi), 
		     m.z + r * cos(theta))
end



function samples(first_coordinate::Real, second_coordinate::Real, b::Int, h::Int, m::VecR3, r::Real, density::Int)::Any
	"""
		Eingabe: - first_coordinate:
			 - second_coordinate:
			 - b: 
			 - h:
			 - m:
			 - r: 
			 - density:

		Ausgabe: 
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
		Eingabe: - b:
		 	 - h:
			 - data: 
			 - m: 
			 - r: 
			 - density: 
			 - frame: 
			 - y_axis_select: 

		Ausgabe: 

	"""

	frame_height = frame.top - frame.bottom
	frame_width = frame.right - frame.left

	# Bildebene 'image' wird hergestellt
	image = []
	for i in 1 : frame_height
		pixel = []
		for j in 1 : frame_width
			push!(pixel, (255, 192, 203, 0))
		end
		push!(image, pixel)
	end


	# Ist select_axis = 'z', so ist first_coordinate = x und second_coordinate = y,
	# andernfalls ist first_coordinate = x und second_coordinate = z
	for first_coordinate in 1 : b
		for second_coordinate in 1 : h 
			i = (first_coordinate - 1) * h + second_coordinate
			points = samples(first_coordinate, second_coordinate, b, h, m, r, density)
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
