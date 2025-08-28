import yaml
from pathlib import Path
import pytest

ANSIBLE_DIR = Path(__file__).resolve().parents[2] / "ansible"
PLAYBOOKS = list((ANSIBLE_DIR / "playbooks").glob("*.yml"))
ROLES_DIR = ANSIBLE_DIR / "roles"

@pytest.mark.integration
@pytest.mark.parametrize("pb", PLAYBOOKS, ids=[p.name for p in PLAYBOOKS])
def test_roles_in_playbooks_exist(pb):
    """Check that all referenced roles exist in roles/ directory."""
    doc = yaml.safe_load(pb.read_text())
    for play in doc:
        for role in play.get("roles", []):
            role_name = role if isinstance(role, str) else role.get("role")
            assert (ROLES_DIR / role_name).exists(), f"Role '{role_name}' in {pb.name} not found"
