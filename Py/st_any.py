"""
Binary spatial predicate functions for GeoPandas

Translates R sfx::st_any functionality
"""

import numpy as np
import pandas as pd
import geopandas as gpd
from functools import wraps


def st_any(x, at_least=1, at_most=np.inf):
    """
    Check for minimum and maximum occurrences of True from binary logical results
    
    Parameters
    ----------
    x : array-like, Series, or sparse matrix result
        Return object of a spatial binary logical function
    at_least : int, default 1
        Minimal occurrences of True
    at_most : int, default inf  
        Maximum occurrences of True
        
    Returns
    -------
    array-like
        Boolean mask meeting the min/max threshold
    """
    
    if hasattr(x, 'sparse'):
        # Handle sparse matrix results from spatial operations
        counts = np.array([len(row) for row in x])
    elif isinstance(x, (pd.Series, np.ndarray)):
        if x.dtype == bool:
            counts = x.astype(int)
        else:
            counts = x
    else:
        # Assume it's a list of lists or similar
        counts = np.array([len(row) if hasattr(row, '__len__') else int(row) 
                          for row in x])
    
    return (counts >= at_least) & (counts <= at_most)


def _st_any_factory(spatial_func):
    """
    Factory function for creating st_any_* spatial predicates
    
    Parameters
    ----------
    spatial_func : callable
        GeoPandas spatial predicate function
        
    Returns
    -------
    callable
        Wrapped function that returns boolean vector
    """
    
    @wraps(spatial_func)
    def wrapper(x, y, at_least=1, at_most=np.inf, match_crs=True, **kwargs):
        """
        Spatial predicate wrapper with st_any logic
        
        Parameters
        ----------
        x : GeoDataFrame or GeoSeries
            Left spatial data
        y : GeoDataFrame or GeoSeries  
            Right spatial data
        at_least : int, default 1
            Minimal occurrences of True
        at_most : int, default inf
            Maximum occurrences of True
        match_crs : bool, default True
            Should CRS of y be coerced to match x
        **kwargs
            Additional arguments passed to spatial predicate
            
        Returns
        -------
        array-like
            Boolean mask
        """
        
        if not isinstance(x, (gpd.GeoDataFrame, gpd.GeoSeries)):
            raise ValueError("x must be GeoDataFrame or GeoSeries")
        if not isinstance(y, (gpd.GeoDataFrame, gpd.GeoSeries)):
            raise ValueError("y must be GeoDataFrame or GeoSeries")
        
        x_crs = x.crs
        y_crs = y.crs
        
        if (x_crs != y_crs) and match_crs:
            print(f"CRS of 'y' does not match 'x'.\n"
                  f"Setting CRS of 'y' to match 'x'.")
            print(x_crs)
            y = y.to_crs(x_crs)
        
        # Call spatial predicate function
        result = spatial_func(x, y, **kwargs)
        
        # Apply st_any logic
        return st_any(result, at_least, at_most)
    
    return wrapper


# Create st_any_* functions for common spatial predicates
st_any_intersects = _st_any_factory(lambda x, y, **kw: x.intersects(y))
st_any_contains = _st_any_factory(lambda x, y, **kw: x.contains(y))
st_any_within = _st_any_factory(lambda x, y, **kw: x.within(y))
st_any_touches = _st_any_factory(lambda x, y, **kw: x.touches(y))
st_any_crosses = _st_any_factory(lambda x, y, **kw: x.crosses(y))  
st_any_overlaps = _st_any_factory(lambda x, y, **kw: x.overlaps(y))
st_any_covers = _st_any_factory(lambda x, y, **kw: x.covers(y))
st_any_covered_by = _st_any_factory(lambda x, y, **kw: x.covered_by(y))
st_any_disjoint = _st_any_factory(lambda x, y, **kw: x.disjoint(y))

def st_any_equals(x, y, at_least=1, at_most=np.inf, match_crs=True, **kwargs):
    """Spatial equals with st_any logic"""
    return _st_any_factory(lambda x, y, **kw: x.equals(y))(
        x, y, at_least, at_most, match_crs, **kwargs)

def st_any_equals_exact(x, y, tolerance, at_least=1, at_most=np.inf, 
                       match_crs=True, **kwargs):
    """Spatial equals_exact with st_any logic"""
    return _st_any_factory(lambda x, y, **kw: x.equals_exact(y, tolerance))(
        x, y, at_least, at_most, match_crs, **kwargs)

def st_any_is_within_distance(x, y, distance, at_least=1, at_most=np.inf,
                             match_crs=True, **kwargs):
    """Spatial is_within_distance with st_any logic"""
    return _st_any_factory(lambda x, y, **kw: x.distance(y) <= distance)(
        x, y, at_least, at_most, match_crs, **kwargs)