"""
Density computation backends for 2D spatial data

Implements kde2d and bkde2D methods for kernel density estimation
"""

import numpy as np
import pandas as pd
from sklearn.neighbors import KernelDensity
from scipy.stats import gaussian_kde
from scipy.spatial.distance import pdist
import warnings


def _compute_kde2d(data, return_geometry="point", bw=None, n=200,
                   x_expansion=None, y_expansion=None):
    """
    Compute 2D kernel density using Gaussian KDE
    
    Parameters
    ----------
    data : array-like, shape (n_samples, 2)
        Coordinate matrix with X, Y columns
    return_geometry : str
        Return geometry type
    bw : float or array-like, optional
        Bandwidth parameter
    n : int
        Grid size
    x_expansion : float, optional
        X-axis expansion factor
    y_expansion : float, optional
        Y-axis expansion factor
        
    Returns
    -------
    DataFrame
        Reshaped density data
    """
    
    _check_for_coords(data)
    lims = _compute_limits(data, return_geometry, x_expansion, y_expansion)
    bw = _check_for_bw(bw, data, method="kde2d")
    
    # Create grid
    x_grid = np.linspace(lims[0], lims[1], n)
    y_grid = np.linspace(lims[2], lims[3], n)
    xx, yy = np.meshgrid(x_grid, y_grid)
    
    # Compute KDE using scipy
    kde = gaussian_kde(data.T, bw_method=bw)
    positions = np.vstack([xx.ravel(), yy.ravel()])
    density = kde(positions).reshape(xx.shape)
    
    # Package results
    dens = {
        'x': x_grid,
        'y': y_grid, 
        'z': density
    }
    
    df = _reshape_density(data, dens, return_geometry)
    return df


def _compute_bkde2d(data, return_geometry="point", bw=None, grid_size=[51, 51],
                    x_expansion=None, y_expansion=None, truncate=True):
    """
    Compute binned 2D kernel density estimation
    
    Parameters
    ----------
    data : array-like, shape (n_samples, 2)
        Coordinate matrix with X, Y columns
    return_geometry : str
        Return geometry type
    bw : float or array-like, optional
        Bandwidth parameter
    grid_size : list, default [51, 51]
        Grid dimensions
    x_expansion : float, optional
        X-axis expansion factor  
    y_expansion : float, optional
        Y-axis expansion factor
    truncate : bool, default True
        Whether to truncate at boundaries
        
    Returns
    -------
    DataFrame
        Reshaped density data
    """
    
    _check_for_coords(data)
    bw = _check_for_bw(bw, data, method="bkde2D")
    
    if not isinstance(grid_size, list):
        grid_size = [grid_size, grid_size]
    
    lims = _compute_limits(data, return_geometry, x_expansion, y_expansion, 
                          bw, method="bkde2D")
    
    # Use scikit-learn KernelDensity as approximation
    # (R's KernSmooth::bkde2D is more specialized)
    kde = KernelDensity(bandwidth=np.mean(bw), kernel='gaussian')
    kde.fit(data)
    
    # Create grid
    x_grid = np.linspace(lims[0][0], lims[0][1], grid_size[0])
    y_grid = np.linspace(lims[1][0], lims[1][1], grid_size[1])
    xx, yy = np.meshgrid(x_grid, y_grid)
    
    positions = np.vstack([xx.ravel(), yy.ravel()]).T
    log_density = kde.score_samples(positions)
    density = np.exp(log_density).reshape(xx.shape)
    
    # Package results
    dens = {
        'x': x_grid,
        'y': y_grid,
        'z': density
    }
    
    df = _reshape_density(data, dens, return_geometry)
    return df


def _names_exist(x, names):
    """Check if column names exist in array/dataframe"""
    if hasattr(x, 'columns'):
        return all(name in x.columns for name in names)
    elif isinstance(x, np.ndarray) and x.ndim == 2:
        return x.shape[1] >= len(names)
    return False


def _check_for_coords(x):
    """Validate coordinate data has X, Y columns"""
    if isinstance(x, np.ndarray):
        if x.ndim != 2 or x.shape[1] < 2:
            raise ValueError("Data must be coordinate matrix with at least 2 columns")
    elif hasattr(x, 'columns'):
        if not _names_exist(x, ['X', 'Y']):
            raise ValueError("Data must contain X and Y columns")
    else:
        raise ValueError("Data must be coordinate matrix")


def _as_matrix(*args):
    """Convert arguments to matrix format"""
    return np.column_stack(args)


# Import helper functions that will be defined in other modules
from .limits import _compute_limits
from .bandwidth import _check_for_bw  
from .density_reshape import _reshape_density