"""
Bandwidth estimation for kernel density estimation
"""

import numpy as np
from scipy.stats import gaussian_kde
from sklearn.neighbors import KernelDensity
import warnings


def _check_for_bw(x, data, method):
    """
    Check and estimate bandwidth if not provided
    
    Parameters
    ----------
    x : float, array-like, or None
        Bandwidth parameter
    data : array-like
        Coordinate data
    method : str
        Density estimation method
        
    Returns
    -------
    float or array-like
        Bandwidth parameter
    """
    if x is None:
        x = _estimate_bw(data, method=method)
        print(f"No bandwidth provided, using estimate: {x}")
    
    return x


def _estimate_bw(data, method="kde2d"):
    """
    Estimate bandwidth for kernel density estimation
    
    Parameters
    ----------
    data : array-like, shape (n_samples, 2)
        Coordinate data
    method : str, default "kde2d"
        Density estimation method
        
    Returns
    -------
    float or array-like
        Estimated bandwidth
    """
    
    np.random.seed(1814)  # For reproducibility
    
    if isinstance(data, np.ndarray):
        x_coords = data[:, 0]
        y_coords = data[:, 1]
    else:
        x_coords = data['X']
        y_coords = data['Y']
    
    if method == "bkde2D":
        # Use Silverman's rule of thumb for each dimension
        bw_x = _silverman_bandwidth(x_coords)
        bw_y = _silverman_bandwidth(y_coords)
        return [bw_x, bw_y]
        
    elif method == "kde2d":
        # Use Silverman's rule of thumb for each dimension  
        bw_x = _silverman_bandwidth(x_coords)
        bw_y = _silverman_bandwidth(y_coords)
        return [bw_x, bw_y]
    
    else:
        raise ValueError(f"Unknown method: {method}")


def _silverman_bandwidth(x):
    """
    Silverman's rule of thumb for bandwidth estimation
    
    Parameters
    ----------
    x : array-like
        1D data
        
    Returns
    -------
    float
        Bandwidth estimate
    """
    x = np.asarray(x)
    n = len(x)
    
    # Silverman's rule: bw = 0.9 * min(std, IQR/1.34) * n^(-1/5)
    std_x = np.std(x)
    iqr_x = np.percentile(x, 75) - np.percentile(x, 25)
    
    bw = 0.9 * min(std_x, iqr_x / 1.34) * (n ** (-1/5))
    
    return bw


def _scott_bandwidth(x):
    """
    Scott's rule for bandwidth estimation
    
    Parameters
    ----------
    x : array-like
        1D data
        
    Returns
    -------
    float
        Bandwidth estimate  
    """
    x = np.asarray(x)
    n = len(x)
    
    # Scott's rule: bw = std * n^(-1/(d+4)) where d=1 for 1D
    bw = np.std(x) * (n ** (-1/5))
    
    return bw