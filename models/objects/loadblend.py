import bpy
import csv
import os
datadir = os.environ['DATADIR']
fp = os.path.join(datadir, "mu", "geoms6.csv")

with open( fp ) as csvfile:
    rdr = csv.reader( csvfile )
    for i, row in enumerate( rdr ):
      # print(i, row)
      if i != 0:
        x, y, z, r = row
        location = (float(x), float(y), float(z))
        bpy.ops.mesh.primitive_uv_sphere_add(size=float(r), location=location)
        # if i == 0: continue # Skip column titles
        # lon, lat = row[3:5]

        # # Generate UV sphere at x = lon and y = lat (and z = 0 )
        # bpy.ops.mesh.primitive_uv_sphere_add( location = ( float(lon), float(lat), 0 ) )