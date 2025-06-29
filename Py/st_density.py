"""
2D spatial density estimation for Python

Translates R sfx::st_density functionality using GeoPandas and scikit-learn
"""

import numpy as np
import pandas as pd
import geopandas as gpd
from sklearn.neighbors import KernelDensity
from scipy.stats import gaussian_kde
from scipy.spatial.distance import pdist
import warnings

# Import helper functions
from .density_compute import _compute_kde2d, _compute_bkde2d


def st_density(x, return_geometry="point", method="kde2d", bw=None, n=200, 
               bins=None, truncate=True, x_expansion=None, y_expansion=None,
               levels_low=None, levels_high=None):
    """
    Compute 2D density
    
    Choose from methods 'kde2d' and 'bkde2D', and various return geometries
    
    Parameters
    ----------
    x : GeoDataFrame or GeoSeries
        Spatial data
    return_geometry : str, default "point"  
        What gets returned ("point", "grid", "raster", "polygon", "isoband")
    method : str, default "kde2d"
        How should density be computed ("kde2d", "bkde2D")
    bw : float or array-like, optional
        Binwidth/bandwidth
    n : int or array-like, default 200
        Grid size  
    bins : int, optional
        Number of contour bins
    truncate : bool, default True
        See KernelDensity truncate parameter
    x_expansion : float, optional
        Expansion multiple applied to x-range
    y_expansion : float, optional  
        Expansion multiple applied to y-range
    levels_low : array-like, optional
        Low breakpoints for isolines and isobands
    levels_high : array-like, optional
        High breakpoints for isolines and isobands
        
    Returns
    -------
    GeoDataFrame or DataFrame
        Density estimates with geometry or coordinates
    """
    
    if not isinstance(x, (gpd.GeoDataFrame, gpd.GeoSeries)):
        raise ValueError("x must be a GeoDataFrame or GeoSeries")
        
    # Extract coordinates
    if hasattr(x, 'geometry'):
        coords = np.column_stack([x.geometry.x, x.geometry.y])
    else:
        coords = np.column_stack([x.x, x.y])
    
    x_crs = x.crs if hasattr(x, 'crs') else None
    
    if n is None:
        n = 200 if method == "kde2d" else [51, 51]
    
    # Compute density by method
    if method == "kde2d":
        result = _compute_kde2d(coords, return_geometry, bw, n, 
                               x_expansion, y_expansion)
    elif method == "bkde2D":
        result = _compute_bkde2d(coords, return_geometry, bw, n,
                                x_expansion, y_expansion, truncate)
    else:
        raise ValueError(f"Unknown method: {method}")
    
    # Handle return geometry
    if return_geometry == "point":
        # Add density columns to original data
        if isinstance(x, gpd.GeoDataFrame):
            x = x.copy()
            x['density'] = result['density']  
            x['ndensity'] = result['ndensity']
            return x
        else:
            df = pd.DataFrame({
                'x': coords[:, 0],
                'y': coords[:, 1], 
                'density': result['density'],
                'ndensity': result['ndensity']
            })
            return gpd.GeoDataFrame(df, geometry=gpd.points_from_xy(df.x, df.y), crs=x_crs)
            
    elif return_geometry == "grid":
        return gpd.GeoDataFrame(result, 
                               geometry=gpd.points_from_xy(result.x, result.y), 
                               crs=x_crs)
    
    elif return_geometry == "raster":
        # Convert to raster format (could use rasterio/xarray)
        return result  # Simplified for now
        
    elif return_geometry == "isoband":
        if levels_high is None or levels_low is None:
            levels_low = 0.05 * np.arange(21)
            levels_high = 0.05 * np.arange(1, 22)
        
        # Create contour polygons using matplotlib/skimage
        # Simplified implementation
        return result
        
    else:
        raise ValueError(f"Unknown return_geometry: {return_geometry}")