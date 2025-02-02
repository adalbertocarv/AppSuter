from shapely.geometry import LineString, Point

def find_interpolation_factor(linestring_coords, point):
    # Cria a LineString
    linestring = LineString(linestring_coords)
    point_geometry = Point(point[1], point[0])  # (lon, lat)

    # Encontra a posição do ponto projetado ao longo da linha
    projected_distance = linestring.project(point_geometry)

    # Retorna o fator de interpolação (0.0 = início, 1.0 = final)
    factor = projected_distance / linestring.length
    return factor

# Coordenadas da LineString
linestring_coords = [
    (-15.794478, -47.882604),
    (-15.794422, -47.882602),
    (-15.794369, -47.882647),
    (-15.794325, -47.882671),
    (-15.79406, -47.882584),
    (-15.793811, -47.882502)
]

# Pontos a verificar
points = [
    (--15.794478, -47.882604),  # Exato no início
    (-15.794422, -47.882602),  # Exato na linha
    (-15.794213870967742, -47.88263451612903),  # Ponto intermediário
    (-15.794332333333333, -47.882667),
    (-15.794325,-47.882671),
    (-15.794316451612904, -47.88266819354839),
    (-15.794119838709678,-47.88260364516129),
    (-15.793811,-47.882502)
]

print("Fatores de interpolação para os pontos:")
for point in points:
    factor = find_interpolation_factor(linestring_coords, point)
    print(f"Ponto: {point} -> Fator de interpolação: {factor:.4f}")
