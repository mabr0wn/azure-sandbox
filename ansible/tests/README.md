# Ansible Unit Tests

Lightweight “unit” checks that run fast and don’t touch real infra. These tests validate YAML, playbook syntax, lint rules, and small Python bits (e.g., custom filters). For full role/integration testing, use Molecule separately.

## Goals

* Catch errors **before** pushing: bad YAML, broken playbooks, deprecated options.
* Keep tests **offline & hermetic** using local **fixtures** (`inventory.yml`, `group_vars`, `host_vars`).
* Make it easy to run in **CI** (GitHub Actions) and locally.

## Layout

```
ansible/
├─ playbooks/
├─ roles/
└─ tests/
   └─ unit/
      ├─ __init__.py
      ├─ conftest.py
      ├─ test_playbooks.py
      ├─ test_roles.py
      ├─ test_filters.py
      └─ fixtures/
         ├─ inventory.yml
         ├─ group_vars/all.yml
         └─ host_vars/example.yml
```

## Prereqs

Create a venv and install tooling:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -U pip
pip install ansible pytest pytest-ansible ansible-lint yamllint
```

## Running Tests (from repo root)

```bash
# Optional: ensure ansible finds your config/roles
export ANSIBLE_CONFIG=ansible/ansible.cfg
export ANSIBLE_ROLES_PATH=ansible/roles

# Run all unit tests
pytest -q ansible/tests/unit

# Just lint (useful while editing)
yamllint ansible/
ansible-lint ansible/
```

## What the default tests can cover

* **`test_playbooks.py`** – run `ansible-playbook --syntax-check` on every playbook in `ansible/playbooks/`.
* **`test_roles.py`** – run `ansible-lint` against roles and catch deprecated/unsafe patterns.
* **`test_filters.py`** – unit test any custom filter/plugins (pure Python, no remote hosts).
* **`conftest.py`** – centralizes paths/env and provides fixtures for inventory/vars.

### Example: `test_playbooks.py`

```python
import os
from pathlib import Path
import subprocess
import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]  # repo/
PLAYBOOK_DIR = REPO_ROOT / "ansible" / "playbooks"

PLAYBOOKS = sorted([p for p in PLAYBOOK_DIR.glob("*.yml") if p.is_file()])

@pytest.mark.parametrize("pb", PLAYBOOKS, ids=[p.name for p in PLAYBOOKS])
def test_syntax_check(pb):
    """Ensure each playbook passes ansible syntax-check."""
    cmd = ["ansible-playbook", "--syntax-check", str(pb)]
    proc = subprocess.run(cmd, cwd=REPO_ROOT, capture_output=True, text=True)
    assert proc.returncode == 0, f"Syntax check failed for {pb.name}:\n{proc.stdout}\n{proc.stderr}"
```

### Example: `conftest.py`

```python
import os
from pathlib import Path
import pytest

@pytest.fixture(scope="session", autouse=True)
def set_ansible_env():
    repo = Path(__file__).resolve().parents[3]
    os.environ.setdefault("ANSIBLE_CONFIG", str(repo / "ansible" / "ansible.cfg"))
    os.environ.setdefault("ANSIBLE_ROLES_PATH", str(repo / "ansible" / "roles"))
    yield
```

## Fixtures

Edit the sample fixtures to mirror a minimal, safe environment:

* `fixtures/inventory.yml` – small static inventory used by tests.
* `fixtures/group_vars/all.yml` and `fixtures/host_vars/example.yml` – defaults/overrides for rendering.

## CI (GitHub Actions snippet)

Create `.github/workflows/ansible-unit.yml`:

```yaml
name: ansible-unit
on: [push, pull_request]
jobs:
  unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: python -m venv .venv && . .venv/bin/activate && pip install -U pip
      - run: . .venv/bin/activate && pip install ansible pytest pytest-ansible ansible-lint yamllint
      - run: . .venv/bin/activate && yamllint ansible && ansible-lint ansible
      - run: . .venv/bin/activate && pytest -q ansible/tests/unit
```

## Tips

* Keep tests **fast and deterministic** (no network calls).
* Pin tool versions in `requirements-dev.txt` if you want reproducibility.
* Use Molecule for role integration with containers/VMs.

---
