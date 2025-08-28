# ansible/tests/integration/test_linux_baseline_integration.py
from pathlib import Path
import os
import subprocess
import pytest

REPO_ROOT   = Path(__file__).resolve().parents[3]
ANSIBLE_DIR = REPO_ROOT / "ansible"
PLAYBOOK    = ANSIBLE_DIR / "playbooks" / "ping_test.yml"   # or whichever baseline playbook you intend

@pytest.mark.integration
@pytest.mark.linux
def test_baseline_integration(tmp_path):
    """
    Run a baseline playbook in check/syntax mode using an isolated inventory.
    Avoids loading dynamic Azure inventory and any vaulted group_vars.
    """
    # 1) Create an isolated inventory in a temp dir
    inv_dir = tmp_path / "inv"
    inv_dir.mkdir()
    (inv_dir / "hosts.ini").write_text(
        "[local]\nlocalhost ansible_connection=local\n"
    )
    # Provide an empty group_vars dir so Ansible won’t walk back to your project’s vaulted vars
    (inv_dir / "group_vars").mkdir()

    env = os.environ.copy()
    # 2) Make sure no global inventory interferes
    env.pop("ANSIBLE_INVENTORY", None)
    # Optional: if your shell has ANSIBLE_CONFIG pointing to project cfg, remove it
    env.pop("ANSIBLE_CONFIG", None)

    # 3) Run syntax-check (or add --check if you want dry-run)
    cmd = [
        "ansible-playbook",
        "-i", str(inv_dir / "hosts.ini"),
        "--syntax-check",
        str(PLAYBOOK)
    ]

    proc = subprocess.run(cmd, cwd=ANSIBLE_DIR, env=env, capture_output=True, text=True)
    assert proc.returncode == 0, f"Baseline failed:\n{proc.stdout}\n{proc.stderr}"
