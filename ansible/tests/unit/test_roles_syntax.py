import subprocess
from pathlib import Path
import pytest

# Base dirs
REPO_ROOT   = Path(__file__).resolve().parents[3]   # go up to repo root
ANSIBLE_DIR = REPO_ROOT / 'ansible'
ROLES_DIR   = ANSIBLE_DIR / 'roles'

@pytest.mark.integration
def test_roles_directory_exists():
    """Ensure roles/ directory exists for Ansible playbooks"""
    assert ROLES_DIR.exists(), 'roles/ directory missing'

@pytest.mark.integration
def test_roles_are_listed():
    """Optionally, check that at least one role folder is present"""
    roles = [p for p in ROLES_DIR.iterdir() if p.is_dir()]
    assert roles, "No roles found in ansible/roles"

@pytest.mark.integration
def test_ansible_roles_path_seen():
    """Run `ansible-config dump` to verify roles_path includes ansible/roles"""
    proc = subprocess.run(
        ["ansible-config", "dump"],
        cwd=ANSIBLE_DIR,
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 0, f"ansible-config failed: {proc.stderr}"
    assert str(ROLES_DIR) in proc.stdout, f"{ROLES_DIR} not in Ansible role search path"
