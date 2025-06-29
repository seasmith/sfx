"""
Utility functions for spatial operations
"""

import numpy as np


def paste_op(lhs, rhs):
    """
    String concatenation operator (translates R's %P%)
    
    Parameters
    ----------
    lhs : str
        Left hand side string
    rhs : str  
        Right hand side string
        
    Returns
    -------
    str
        Concatenated string
    """
    return str(lhs) + str(rhs)


class PasteOperator:
    """Class to enable %P% operator syntax via overloading"""
    
    def __init__(self, value):
        self.value = str(value)
    
    def __mod__(self, other):
        if hasattr(other, 'value'):
            return PasteOperator(self.value + other.value)
        else:
            return PasteOperator(self.value + str(other))
    
    def __str__(self):
        return self.value
    
    def __repr__(self):
        return f"PasteOperator('{self.value}')"


def P(value):
    """
    Create PasteOperator instance for chaining
    
    Parameters
    ----------
    value : str
        Initial value
        
    Returns
    -------
    PasteOperator
        Chainable paste operator
        
    Examples
    --------
    >>> result = P("Hello") % P(" ") % P("World")
    >>> str(result)
    'Hello World'
    """
    return PasteOperator(value)