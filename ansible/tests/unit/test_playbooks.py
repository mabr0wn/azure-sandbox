# ansible/tests/unit/test_playbooks.py
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
    cmd = ["ansible-playbook", "--syntax-check", "-i", "localhost,", str(pb)]
    proc = subprocess.run(
        cmd,
        cwd=str(ANSIBLE_DIR),          # <-- use ansible/ as CWD
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 0, f"Syntax check failed for {pb.name}:\n{proc.stdout}\n{proc.stderr}"
