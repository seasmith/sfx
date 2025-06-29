"""
Compute spatial limits and expansions for density estimation
"""

import numpy as np


def _compute_expansion(return_type, method):
    """
    Compute default expansion factors based on return type and method
    
    Parameters
    ----------
    return_type : str
        Type of return geometry
    method : str
        Density estimation method
        
    Returns
    -------
    tuple
        (x_expansion, y_expansion)
    """
    if return_type == "polygon" and method == "kde2d":
        x_expansion = 0.15
        y_expansion = 0.15
    else:
        x_expansion = 0.0
        y_expansion = 0.0
    
    return x_expansion, y_expansion


def _compute_limits(data, return_type, x_expansion, y_expansion, 
                   bw=None, method="kde2d"):
    """
    Compute spatial limits for density estimation
    
    Parameters
    ----------
    data : array-like, shape (n_samples, 2)
        Coordinate data
    return_type : str
        Return geometry type
    x_expansion : float, optional
        X-axis expansion factor
    y_expansion : float, optional
        Y-axis expansion factor  
    bw : float or array-like, optional
        Bandwidth (used for bkde2D method)
    method : str, default "kde2d"
        Density estimation method
        
    Returns
    -------
    list or tuple
        Spatial limits [xmin, xmax, ymin, ymax] for kde2d
        or [[xmin, xmax], [ymin, ymax]] for bkde2D
    """
    
    if isinstance(data, np.ndarray):
        x_coords = data[:, 0]
        y_coords = data[:, 1]
    else:
        x_coords = data['X']
        y_coords = data['Y']
    
    if method == "kde2d":
        # Handle X limits
        if x_expansion is None:
            rng_x = [np.min(x_coords), np.max(x_coords)]
        else:
            if not isinstance(x_expansion, (list, np.ndarray)):
                x_expansion = [x_expansion, x_expansion]
            
            rng_x = [np.min(x_coords), np.max(x_coords)]
            dist_x = rng_x[1] - rng_x[0]
            
            rng_x[0] = rng_x[0] - abs(x_expansion[0] * dist_x)
            rng_x[1] = rng_x[1] + abs(x_expansion[1] * dist_x)
        
        # Handle Y limits  
        if y_expansion is None:
            rng_y = [np.min(y_coords), np.max(y_coords)]
        else:
            if not isinstance(y_expansion, (list, np.ndarray)):
                y_expansion = [y_expansion, y_expansion]
                
            rng_y = [np.min(y_coords), np.max(y_coords)]
            dist_y = rng_y[1] - rng_y[0]
            
            rng_y[0] = rng_y[0] - abs(y_expansion[0] * dist_y)
            rng_y[1] = rng_y[1] + abs(y_expansion[1] * dist_y)
            
        return [rng_x[0], rng_x[1], rng_y[0], rng_y[1]]
    
    elif method == "bkde2D":
        # Handle X limits
        if x_expansion is None:
            rng_x = [np.min(x_coords), np.max(x_coords)]
            rng_x[0] = rng_x[0] - 1.75 * bw[0]
            rng_x[1] = rng_x[1] + 1.75 * bw[0]
        else:
            rng_x = x_expansion
            
        # Handle Y limits
        if y_expansion is None:
            rng_y = [np.min(y_coords), np.max(y_coords)]  
            rng_y[0] = rng_y[0] - 1.75 * bw[1]
            rng_y[1] = rng_y[1] + 1.75 * bw[1]
        else:
            rng_y = y_expansion
            
        return [rng_x, rng_y]
    
    else:
        raise ValueError(f"Unknown method: {method}")