"""
Spatial join operations for GeoPandas

Translates R sfx spatial join functionality
"""

import geopandas as gpd
from .st_any import st_any


def st_left_join(x, y, **kwargs):
    """
    Left spatial join
    
    Parameters
    ----------
    x : GeoDataFrame
        Left spatial data
    y : GeoDataFrame  
        Right spatial data
    **kwargs
        Additional arguments passed to sjoin
        
    Returns
    -------
    GeoDataFrame
        Left joined result
    """
    return gpd.sjoin(x, y, how='left', **kwargs)


def st_inner_join(x, y, **kwargs):
    """
    Inner spatial join
    
    Parameters
    ----------
    x : GeoDataFrame
        Left spatial data
    y : GeoDataFrame
        Right spatial data  
    **kwargs
        Additional arguments passed to sjoin
        
    Returns
    -------
    GeoDataFrame
        Inner joined result
    """
    return gpd.sjoin(x, y, how='inner', **kwargs)


def st_right_join(x, y, **kwargs):
    """
    Right spatial join (implemented as left join with swapped arguments)
    
    Parameters
    ----------
    x : GeoDataFrame
        Left spatial data
    y : GeoDataFrame
        Right spatial data
    **kwargs
        Additional arguments passed to sjoin
        
    Returns
    -------
    GeoDataFrame
        Right joined result
    """
    return gpd.sjoin(y, x, how='left', **kwargs)


def st_semi_join(x, y, predicate='intersects', **kwargs):
    """
    Semi spatial join - returns rows from x that have matches in y
    
    Parameters
    ----------
    x : GeoDataFrame
        Left spatial data
    y : GeoDataFrame
        Right spatial data
    predicate : str, default 'intersects'
        Spatial predicate to use
    **kwargs
        Additional arguments
        
    Returns
    -------
    GeoDataFrame
        Filtered x with matches in y
    """
    
    if not isinstance(x, gpd.GeoDataFrame):
        raise ValueError("x must be GeoDataFrame")
    if not isinstance(y, gpd.GeoDataFrame):
        raise ValueError("y must be GeoDataFrame")
    
    # Get spatial predicate function
    if predicate == 'intersects':
        spatial_result = x.intersects(y.unary_union)
    elif predicate == 'within':
        spatial_result = x.within(y.unary_union)
    elif predicate == 'contains':
        spatial_result = x.contains(y.unary_union)
    elif predicate == 'touches':
        spatial_result = x.touches(y.unary_union)
    elif predicate == 'crosses':
        spatial_result = x.crosses(y.unary_union)
    elif predicate == 'overlaps':
        spatial_result = x.overlaps(y.unary_union)
    elif predicate == 'covers':
        spatial_result = x.covers(y.unary_union)
    elif predicate == 'covered_by':
        spatial_result = x.covered_by(y.unary_union)
    else:
        raise ValueError(f"Unknown predicate: {predicate}")
    
    return x[spatial_result]


def st_anti_join(x, y, predicate='intersects', **kwargs):
    """
    Anti spatial join - returns rows from x that have no matches in y
    
    Parameters
    ----------
    x : GeoDataFrame
        Left spatial data
    y : GeoDataFrame
        Right spatial data
    predicate : str, default 'intersects'
        Spatial predicate to use
    **kwargs
        Additional arguments
        
    Returns
    -------
    GeoDataFrame
        Filtered x without matches in y
    """
    
    if not isinstance(x, gpd.GeoDataFrame):
        raise ValueError("x must be GeoDataFrame")
    if not isinstance(y, gpd.GeoDataFrame):
        raise ValueError("y must be GeoDataFrame")
    
    # Get spatial predicate function
    if predicate == 'intersects':
        spatial_result = x.intersects(y.unary_union)
    elif predicate == 'within':
        spatial_result = x.within(y.unary_union)
    elif predicate == 'contains':
        spatial_result = x.contains(y.unary_union)
    elif predicate == 'touches':
        spatial_result = x.touches(y.unary_union)
    elif predicate == 'crosses':
        spatial_result = x.crosses(y.unary_union)
    elif predicate == 'overlaps':
        spatial_result = x.overlaps(y.unary_union)
    elif predicate == 'covers':
        spatial_result = x.covers(y.unary_union)
    elif predicate == 'covered_by':
        spatial_result = x.covered_by(y.unary_union)
    else:
        raise ValueError(f"Unknown predicate: {predicate}")
    
    return x[~spatial_result]