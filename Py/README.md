# sfx-py: Python Translation of R sfx Package

A Python translation of the R `sfx` package, providing spatial extensions for GeoPandas with focus on 2D density estimation and spatial operations.

## Features

### Core Functions
- **`st_density()`** - 2D spatial density estimation with multiple methods and output formats
- **Spatial predicates** - `st_any_*` functions for binary spatial operations  
- **Spatial joins** - Enhanced join operations (`st_semi_join`, `st_anti_join`, etc.)
- **Extent utilities** - Bounding box and spatial extent functions

### Density Estimation Methods
- **kde2d** - Gaussian kernel density estimation using scipy
- **bkde2D** - Binned kernel density estimation using scikit-learn

### Return Geometries  
- **point** - Interpolate density back to original points
- **grid** - Regular grid of density values
- **raster** - Raster format (planned)
- **isoband** - Contour polygons (planned)

## Dependencies

```python
numpy
pandas
geopandas
scikit-learn
scipy
shapely
```

## Basic Usage

```python
import geopandas as gpd
from sfx import st_density, st_any_intersects

# Load spatial data
points = gpd.read_file("points.geojson")

# Compute 2D density
density_grid = st_density(points, return_geometry="grid", method="kde2d")

# Spatial predicates
polygons = gpd.read_file("polygons.geojson") 
intersecting = st_any_intersects(points, polygons)
```

## File Structure

```
Py/
├── __init__.py           # Package initialization and exports
├── st_density.py         # Main density estimation interface
├── density_compute.py    # Computational backends (kde2d, bkde2D)
├── density_reshape.py    # Output format reshaping
├── limits.py            # Spatial limits computation  
├── bandwidth.py         # Bandwidth estimation
├── st_any.py           # Binary spatial predicates
├── st_joins.py         # Spatial join operations
├── st_extent.py        # Bounding box utilities
└── utils.py            # General utilities
```

## Translation Notes

This Python translation aims to preserve the API and functionality of the original R package while leveraging Python's spatial ecosystem (GeoPandas, scipy, scikit-learn). Some adaptations were made to fit Python conventions and available libraries.

## Status

✅ Core density estimation  
✅ Spatial predicates and joins  
✅ Extent and utility functions  
🚧 Raster and isoband outputs (partial)  
🚧 Complete feature parity testing