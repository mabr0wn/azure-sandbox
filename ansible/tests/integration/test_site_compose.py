from pathlib import Path
import subprocess
import pytest

# <repo>/ansible/tests/integration/test_site_compose.py
# parents[0] -> integration, [1] -> tests, [2] -> ansible
ANSIBLE_DIR   = Path(__file__).resolve().parents[2]
SITE_PLAYBOOK = ANSIBLE_DIR / "playbooks" / "site.yml"

@pytest.mark.integration
def test_site_compose_runs_in_check_mode():
    """Dry-run site.yml to ensure all roles/tasks load."""
    proc = subprocess.run(
        ["ansible-playbook", "--syntax-check", str(SITE_PLAYBOOK)],
        cwd=ANSIBLE_DIR, capture_output=True, text=True
    )
    assert proc.returncode == 0, f"site.yml failed:\n{proc.stdout}\n{proc.stderr}"
