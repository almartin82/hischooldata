"""
Tests for pyhischooldata Python wrapper.

Minimal smoke tests - the actual data logic is tested by R testthat.
These just verify the Python wrapper imports and exposes expected functions.
"""

import pytest


def test_import_package():
    """Package imports successfully."""
    import pyhischooldata
    assert pyhischooldata is not None


def test_has_fetch_enr():
    """fetch_enr function is available."""
    import pyhischooldata
    assert hasattr(pyhischooldata, 'fetch_enr')
    assert callable(pyhischooldata.fetch_enr)


def test_has_get_available_years():
    """get_available_years function is available."""
    import pyhischooldata
    assert hasattr(pyhischooldata, 'get_available_years')
    assert callable(pyhischooldata.get_available_years)


def test_has_version():
    """Package has a version string."""
    import pyhischooldata
    assert hasattr(pyhischooldata, '__version__')
    assert isinstance(pyhischooldata.__version__, str)
