import os
import shutil
import subprocess
from pathlib import Path

import pytest
import yaml


def _find_repo_root(start: Path) -> Path:
    p = start
    while True:
        if (p / "ansible").is_dir() and (p / "README.md").exists():
            return p
        if p == p.parent:
            return start
        p = p.parent


THIS_FILE = Path(__file__).resolve()
REPO_ROOT = _find_repo_root(THIS_FILE)
ANSIBLE_DIR = REPO_ROOT / "ansible"
PLAYBOOK = ANSIBLE_DIR / "playbooks" / "apps-windows.yml"

pytestmark = [pytest.mark.ansible, pytest.mark.integration]


def _require_ansible():
    if shutil.which("ansible-playbook") is None:
        pytest.skip("ansible-playbook not found (activate .venv and install deps).")


def _ansible_env():
    env = os.environ.copy()
    env["ANSIBLE_CONFIG"] = str(ANSIBLE_DIR / "ansible.cfg")
    return env


def test_apps_windows_syntax_only():
    """Fast/CI-safe: validate playbook syntax without connecting to Windows."""
    _require_ansible()
    if not PLAYBOOK.exists():
        pytest.skip(f"Playbook not found: {PLAYBOOK}")

    proc = subprocess.run(
        ["ansible-playbook", "--syntax-check", str(PLAYBOOK)],
        cwd=str(REPO_ROOT),
        env=_ansible_env(),
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 0, f"Syntax check failed:\nSTDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}"


@pytest.mark.skipif(
    not all(os.getenv(k) for k in ["WIN_HOST", "WIN_USER", "WIN_PASS"]),
    reason="Set WIN_HOST/WIN_USER/WIN_PASS to run real WinRM check-mode test.",
)
def test_apps_windows_check_mode(tmp_path):
    """Real integration: run --check against a real Windows host, if creds provided."""
    _require_ansible()
    assert PLAYBOOK.exists(), f"Playbook missing: {PLAYBOOK}"

    host = os.getenv("WIN_HOST")
    user = os.getenv("WIN_USER")
    password = os.getenv("WIN_PASS")

    inv = tmp_path / "inventory.ini"
    inv.write_text(
        "[windows]\n"
        f"{host}\n\n"
        "[windows:vars]\n"
        "ansible_connection=winrm\n"
        "ansible_winrm_transport=ntlm\n"
        "ansible_winrm_server_cert_validation=ignore\n"
        f"ansible_user={user}\n"
        f"ansible_password={password}\n"
    )

    proc = subprocess.run(
        ["ansible-playbook", "-i", str(inv), "--check", str(PLAYBOOK)],
        cwd=str(REPO_ROOT),
        env=_ansible_env(),
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 0, f"--check failed:\nSTDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}"


@pytest.mark.parametrize(
    "expected_task",
    [
        "Download Brave installer",
        "Install VS Code (system-wide)",
        "Install Google Chrome (system-wide)",
        "Install Git for Windows silently",
        "Install Python system-wide, add to PATH",
    ],
)
def test_apps_windows_has_expected_tasks(expected_task):
    if not PLAYBOOK.exists():
        pytest.skip(f"Playbook not found: {PLAYBOOK}")

    data = yaml.safe_load(PLAYBOOK.read_text())
    if isinstance(data, list) and data:
        tasks = data[0].get("tasks", [])
    else:
        tasks = data.get("tasks", []) if isinstance(data, dict) else []

    names = [t.get("name", "") for t in tasks if isinstance(t, dict)]
    assert expected_task in names, f"Missing task: {expected_task}"
