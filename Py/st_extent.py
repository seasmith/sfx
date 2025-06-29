"""
Spatial extent and bounding box utilities for GeoPandas

Translates R sfx extent functionality  
"""

import geopandas as gpd
from shapely.geometry import box


def st_extent(x, return_type="gdf"):
    """
    Return the bounding box as GeoDataFrame or GeoSeries
    
    Parameters
    ----------
    x : GeoDataFrame or GeoSeries
        Spatial data
    return_type : str, default "gdf"
        Return type; either "gdf" (GeoDataFrame) or "gs" (GeoSeries)
        
    Returns
    -------
    GeoDataFrame or GeoSeries
        Bounding box geometry
    """
    
    # Get bounding box
    bounds = x.total_bounds
    bbox_geom = box(*bounds)
    
    if return_type == "gdf":
        return gpd.GeoDataFrame([1], geometry=[bbox_geom], crs=x.crs)
    elif return_type == "gs":
        return gpd.GeoSeries([bbox_geom], crs=x.crs)
    else:
        raise ValueError("return_type must be 'gdf' or 'gs'")


def st_xdist(x):
    """
    Get bounding box x-dimension (width)
    
    Parameters
    ----------
    x : GeoDataFrame, GeoSeries, or bounds array
        Spatial data or bounds
        
    Returns
    -------
    float
        X-dimension distance
    """
    
    if hasattr(x, 'total_bounds'):
        bounds = x.total_bounds
        return bounds[2] - bounds[0]  # xmax - xmin
    elif hasattr(x, '__len__') and len(x) == 4:
        # Assume it's bounds array [xmin, ymin, xmax, ymax]
        return x[2] - x[0]
    else:
        raise ValueError("x must be GeoDataFrame, GeoSeries, or bounds array")


def st_ydist(x):
    """
    Get bounding box y-dimension (height)
    
    Parameters
    ----------
    x : GeoDataFrame, GeoSeries, or bounds array
        Spatial data or bounds
        
    Returns
    -------
    float
        Y-dimension distance
    """
    
    if hasattr(x, 'total_bounds'):
        bounds = x.total_bounds  
        return bounds[3] - bounds[1]  # ymax - ymin
    elif hasattr(x, '__len__') and len(x) == 4:
        # Assume it's bounds array [xmin, ymin, xmax, ymax]
        return x[3] - x[1]
    else:
        raise ValueError("x must be GeoDataFrame, GeoSeries, or bounds array")


def st_xlim(x):
    """
    Get x-axis limits
    
    Parameters
    ---------- 
    x : GeoDataFrame or GeoSeries
        Spatial data
        
    Returns
    -------
    tuple
        (xmin, xmax)
    """
    
    bounds = x.total_bounds
    return (bounds[0], bounds[2])


def st_ylim(x):
    """
    Get y-axis limits
    
    Parameters
    ----------
    x : GeoDataFrame or GeoSeries
        Spatial data
        
    Returns
    -------  
    tuple
        (ymin, ymax)
    """
    
    bounds = x.total_bounds
    return (bounds[1], bounds[3])