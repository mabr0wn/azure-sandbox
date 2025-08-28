import os, pytest
pytestmark = [pytest.mark.system, pytest.mark.windows]
WIN_INV = os.getenv('WIN_INV')  # path to real inventory

@pytest.mark.skipif(not WIN_INV, reason='WIN_INV not set; skipping system tests')
def test_placeholder_real_run():
    assert True

