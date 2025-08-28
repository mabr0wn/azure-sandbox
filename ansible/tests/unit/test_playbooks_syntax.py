# ansible/tests/unit/test_playbooks_syntax.py
import os
import subprocess
from pathlib import Path
import pytest

REPO_ROOT   = Path(__file__).resolve().parents[3]
ANSIBLE_DIR = REPO_ROOT / "ansible"
PLAYBOOK_DIR = ANSIBLE_DIR / "playbooks"
PLAYBOOKS = sorted(p for p in PLAYBOOK_DIR.glob("*.yml") if p.is_file())

@pytest.mark.integration
@pytest.mark.parametrize("pb", PLAYBOOKS, ids=[p.name for p in PLAYBOOKS])
def test_syntax_check(pb):
    env = os.environ.copy()
    env["ANSIBLE_CONFIG"] = str(ANSIBLE_DIR / "ansible.cfg")
    env["ANSIBLE_ROLES_PATH"] = str(ANSIBLE_DIR / "roles")
    cmd = ["ansible-playbook", "--syntax-check", "-i", str(ANSIBLE_DIR / "inventory"), str(pb)]
    proc = subprocess.run(
        cmd,
        cwd=str(REPO_ROOT),
        env=env,
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 0, f"Syntax check failed for {pb.name}:\n{proc.stdout}\n{proc.stderr}"
