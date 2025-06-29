"""
Python translation of R sfx package

Spatial extensions for GeoPandas providing density estimation,
spatial joins, and utility functions.
"""

# Core density functions
from .st_density import st_density

# Spatial utility functions  
from .st_any import (
    st_any,
    st_any_intersects,
    st_any_contains, 
    st_any_within,
    st_any_touches,
    st_any_crosses,
    st_any_overlaps,
    st_any_covers,
    st_any_covered_by,
    st_any_disjoint,
    st_any_equals,
    st_any_equals_exact,
    st_any_is_within_distance
)

# Spatial joins
from .st_joins import (
    st_left_join,
    st_inner_join, 
    st_right_join,
    st_semi_join,
    st_anti_join
)

# Extent and bounding box functions
from .st_extent import (
    st_extent,
    st_xdist,
    st_ydist,
    st_xlim,
    st_ylim
)

# Utility functions
from .utils import paste_op, P

# Internal computation functions (not exported by default)
from . import density_compute
from . import limits
from . import bandwidth
from . import density_reshape

__version__ = "0.1.0"

__all__ = [
    # Core functions
    'st_density',
    
    # st_any functions
    'st_any',
    'st_any_intersects',
    'st_any_contains',
    'st_any_within', 
    'st_any_touches',
    'st_any_crosses',
    'st_any_overlaps',
    'st_any_covers',
    'st_any_covered_by',
    'st_any_disjoint',
    'st_any_equals',
    'st_any_equals_exact',
    'st_any_is_within_distance',
    
    # Spatial joins
    'st_left_join',
    'st_inner_join',
    'st_right_join', 
    'st_semi_join',
    'st_anti_join',
    
    # Extent functions
    'st_extent',
    'st_xdist',
    'st_ydist',
    'st_xlim',
    'st_ylim',
    
    # Utilities
    'paste_op',
    'P'
]