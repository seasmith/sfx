"""
Reshape density results to different output formats
"""

import numpy as np
import pandas as pd
from scipy.interpolate import griddata


def _reshape_density(raw, grid, return_geometry):
    """
    Reshape density to grid or point format
    
    Parameters
    ----------
    raw : array-like
        Original coordinate data
    grid : dict
        Computed density with 'x', 'y', 'z' keys
    return_geometry : str
        Output geometry type
        
    Returns
    -------
    DataFrame
        Reshaped density data
    """
    
    if return_geometry == "point":
        df = _interpolate_density(raw, grid['x'], grid['y'], grid['z'])
    elif return_geometry in ["grid", "raster", "polygon", "contour", "isoband"]:
        df = _expand_density(grid['x'], grid['y'], grid['z'])
    else:
        raise ValueError(f"Unknown return_geometry: {return_geometry}")
    
    # Add normalized density
    df['ndensity'] = df['density'] / df['density'].max()
    
    return df


def _expand_density(x, y, z):
    """
    Expand density grid to long format
    
    Parameters
    ----------
    x : array-like
        X coordinates
    y : array-like  
        Y coordinates
    z : array-like, 2D
        Density values
        
    Returns
    -------
    DataFrame
        Long format density data
    """
    
    xx, yy = np.meshgrid(x, y)
    
    df = pd.DataFrame({
        'x': xx.ravel(),
        'y': yy.ravel(), 
        'density': z.ravel()
    })
    
    return df


def _interpolate_density(raw, x, y, z):
    """
    Interpolate density values back to original point locations
    
    Parameters
    ----------
    raw : array-like
        Original coordinate data  
    x : array-like
        Grid x coordinates
    y : array-like
        Grid y coordinates
    z : array-like, 2D
        Density grid values
        
    Returns
    -------
    DataFrame
        Point density data
    """
    
    if isinstance(raw, np.ndarray):
        raw_x = raw[:, 0]
        raw_y = raw[:, 1]
    else:
        raw_x = raw['X']
        raw_y = raw['Y']
    
    # Create grid coordinates
    xx, yy = np.meshgrid(x, y)
    grid_points = np.column_stack([xx.ravel(), yy.ravel()])
    grid_values = z.ravel()
    
    # Interpolate to original points
    query_points = np.column_stack([raw_x, raw_y])
    interpolated = griddata(grid_points, grid_values, query_points, 
                           method='linear', fill_value=0.0)
    
    df = pd.DataFrame({
        'x': raw_x,
        'y': raw_y,
        'density': interpolated
    })
    
    return df