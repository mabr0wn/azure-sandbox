#!/usr/bin/env bash
set -euo pipefail

# Creates an Ansible testing scaffold under: ansible/tests/{unit,integration,system}
# Safe/idempotent: won't overwrite existing files; writes templates only if missing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TESTS_DIR="${ANSIBLE_DIR}/tests"

echo "Creating test scaffold at: ${TESTS_DIR}"

# ---------- helpers ----------
create_if_missing() { [[ -e "$1" ]] || touch "$1"; }
write_if_missing() {
  local file="$1"; shift
  if [[ ! -e "$file" ]]; then
    mkdir -p "$(dirname "$file")"
    cat >"$file" <<<"$*"
  fi
}

# ---------- directories ----------
mkdir -p \
  "${TESTS_DIR}/unit/ansible" \
  "${TESTS_DIR}/integration/ansible/playbooks" \
  "${TESTS_DIR}/integration/ansible/roles" \
  "${TESTS_DIR}/system/ansible/windows" \
  "${TESTS_DIR}/system/ansible/linux" \
  "${TESTS_DIR}/fixtures/group_vars" \
  "${TESTS_DIR}/fixtures/host_vars" \
  "${TESTS_DIR}/helpers"

# ---------- shared fixtures ----------
create_if_missing "${TESTS_DIR}/fixtures/inventory.yml"
create_if_missing "${TESTS_DIR}/fixtures/group_vars/all.yml"
create_if_missing "${TESTS_DIR}/fixtures/host_vars/example.yml"
create_if_missing "${TESTS_DIR}/helpers/.gitkeep"

# ---------- unit tests (pure Python) ----------
write_if_missing "${TESTS_DIR}/unit/ansible/test_filters.py" \
"# Unit tests for Jinja2/Ansible filters (pure Python).
import pytest

def test_example_filter_smoke():
    assert 1 + 1 == 2
"

# ---------- integration tests: playbooks ----------
write_if_missing "${TESTS_DIR}/integration/ansible/playbooks/test_playbooks_syntax.py" \
"import subprocess
from pathlib import Path
import pytest

REPO_ROOT = Path(__file__).resolve().parents[4]
PLAYBOOK_DIR = REPO_ROOT / 'ansible' / 'playbooks'
PLAYBOOKS = sorted([p for p in PLAYBOOK_DIR.glob('*.yml') if p.is_file()])

@pytest.mark.integration
@pytest.mark.parametrize('pb', PLAYBOOKS, ids=[p.name for p in PLAYBOOKS])
def test_syntax_check(pb):
    proc = subprocess.run(['ansible-playbook', '--syntax-check', str(pb)],
                          cwd=REPO_ROOT, capture_output=True, text=True)
    assert proc.returncode == 0, f'Syntax check failed for {pb.name}:\\n{proc.stdout}\\n{proc.stderr}'
"

# apps-windows.yml specific check-mode + presence checks
write_if_missing "${TESTS_DIR}/integration/ansible/playbooks/test_apps_windows_check.py" \
"import subprocess
from pathlib import Path
import yaml
import pytest

REPO_ROOT = Path(__file__).resolve().parents[4]
PLAYBOOK = REPO_ROOT / 'ansible' / 'playbooks' / 'apps-windows.yml'

@pytest.mark.integration
def test_apps_windows_check_mode(tmp_path):
    inv = tmp_path / 'inventory.ini'
    inv.write_text('[windows]\\nlocalhost ansible_connection=local\\n')
    proc = subprocess.run(['ansible-playbook', '-i', str(inv), '--check', str(PLAYBOOK)],
                          cwd=REPO_ROOT, capture_output=True, text=True)
    assert proc.returncode == 0, f'--check failed:\\n{proc.stdout}\\n{proc.stderr}'

@pytest.mark.integration
def test_apps_windows_has_expected_tasks():
    doc = yaml.safe_load(PLAYBOOK.read_text())
    names = [t.get('name','') for t in doc[0].get('tasks', [])]
    for expected in [
        'Download Brave installer',
        'Install VS Code (system-wide)',
        'Install Google Chrome (system-wide)',
        'Install Git for Windows silently',
        'Install Python system-wide, add to PATH',
    ]:
        assert any(expected == n for n in names), f'Missing task: {expected}'
"

# ---------- integration tests: roles (placeholder) ----------
write_if_missing "${TESTS_DIR}/integration/ansible/roles/test_roles_syntax.py" \
"import subprocess
from pathlib import Path
import pytest

REPO_ROOT = Path(__file__).resolve().parents[4]
ROLES_DIR = REPO_ROOT / 'ansible' / 'roles'

@pytest.mark.integration
def test_roles_directory_exists():
    assert ROLES_DIR.exists(), 'roles/ directory missing'
"

# ---------- system tests (opt-in; real hosts) ----------
write_if_missing "${TESTS_DIR}/system/ansible/windows/test_apps_windows_real.py" \
"import os, pytest
pytestmark = [pytest.mark.system, pytest.mark.windows]
WIN_INV = os.getenv('WIN_INV')  # path to real inventory

@pytest.mark.skipif(not WIN_INV, reason='WIN_INV not set; skipping system tests')
def test_placeholder_real_run():
    assert True
"

write_if_missing "${TESTS_DIR}/system/ansible/linux/test_baseline_real.py" \
"import pytest
pytestmark = [pytest.mark.system, pytest.mark.linux]
def test_placeholder():
    assert True
"

# ---------- pytest.ini (only if missing) ----------
write_if_missing "${ANSIBLE_DIR}/pytest.ini" \
"[pytest]
testpaths = tests
markers =
    unit: fast, pure-Python tests
    integration: syntax / --check / no remote changes
    system: runs against real hosts or cloud resources
    windows: windows-specific
    linux: linux-specific
addopts = -q
"

# ---------- README breadcrumbs ----------
write_if_missing "${TESTS_DIR}/README.md" \
"# Test Layout

- unit/: pure Python tests (no Ansible/remote)
- integration/: ansible syntax + --check (no changes on hosts)
- system/: real hosts (opt-in; gated by env vars)
- fixtures/: shared inventory/group_vars/host_vars
"

echo "Done."
command -v tree >/dev/null 2>&1 && tree -a "${TESTS_DIR}" || ls -R "${TESTS_DIR}"
