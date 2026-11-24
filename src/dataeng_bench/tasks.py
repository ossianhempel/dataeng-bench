"""Load benchmark tasks from disk.

A task is a directory with a ``task.yaml`` metadata file and a ``prompt.md``
that is shown to the model. See docs/task-format.md for the full layout.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
TASKS_DIR = REPO_ROOT / "tasks"

ANSWER_TYPES = {"sql", "structured", "rubric"}
DIFFICULTIES = {"easy", "medium", "hard"}


@dataclass
class Task:
    id: str
    title: str
    category: str
    subcategory: str
    difficulty: str
    answer_type: str
    path: Path
    tags: list[str] = field(default_factory=list)
    sources: list[dict[str, Any]] = field(default_factory=list)
    timeout_seconds: float = 30.0

    @property
    def prompt(self) -> str:
        return (self.path / "prompt.md").read_text()

    def file(self, relative: str) -> Path:
        return self.path / relative

    def read(self, relative: str) -> str:
        return (self.path / relative).read_text()

    def load_yaml(self, relative: str) -> Any:
        return yaml.safe_load(self.read(relative))

    @property
    def reference_path(self) -> Path:
        name = {"sql": "solution.sql", "structured": "answer.json", "rubric": "answer.md"}[
            self.answer_type
        ]
        return self.path / "reference" / name

    @property
    def negative_paths(self) -> list[Path]:
        """Known-wrong answers that the grader must not give full marks."""
        negative_dir = self.path / "negative"
        if not negative_dir.is_dir():
            return []
        return sorted(p for p in negative_dir.iterdir() if p.is_file())


def load_task(path: str | Path) -> Task:
    path = Path(path).resolve()
    meta = yaml.safe_load((path / "task.yaml").read_text())
    task = Task(
        id=meta["id"],
        title=meta["title"],
        category=meta["category"],
        subcategory=meta.get("subcategory", ""),
        difficulty=meta["difficulty"],
        answer_type=meta["answer_type"],
        path=path,
        tags=meta.get("tags", []),
        sources=meta.get("sources", []),
        timeout_seconds=float(meta.get("timeout_seconds", 30)),
    )
    if task.answer_type not in ANSWER_TYPES:
        raise ValueError(f"{task.id}: unknown answer_type {task.answer_type!r}")
    if task.difficulty not in DIFFICULTIES:
        raise ValueError(f"{task.id}: unknown difficulty {task.difficulty!r}")
    return task


def discover_tasks(root: str | Path = TASKS_DIR) -> list[Task]:
    root = Path(root)
    return sorted(
        (load_task(p.parent) for p in root.rglob("task.yaml")), key=lambda t: t.id
    )
