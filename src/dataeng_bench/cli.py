"""Command line entry point.

    dataeng-bench list [--category data_modeling]
    dataeng-bench show <task-dir>
    dataeng-bench grade <task-dir> <answer-file> [--judge-reply FILE] [--json]
    dataeng-bench judge-prompt <task-dir> <answer-file>
    dataeng-bench validate [<task-dir> ...]
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from .grading.grade import grade
from .grading.rubric import build_judge_prompt
from .tasks import TASKS_DIR, discover_tasks, load_task


def _cmd_list(args: argparse.Namespace) -> int:
    for t in discover_tasks():
        if args.category and t.category != args.category:
            continue
        rel = t.path.relative_to(TASKS_DIR)
        print(f"{t.id:45} {t.answer_type:10} {t.difficulty:6} {rel}")
    return 0


def _cmd_show(args: argparse.Namespace) -> int:
    print(load_task(args.task).prompt)
    return 0


def _cmd_grade(args: argparse.Namespace) -> int:
    task = load_task(args.task)
    answer = Path(args.answer).read_text()
    judge = Path(args.judge_reply).read_text() if args.judge_reply else None
    result = grade(task, answer, judge)
    print(json.dumps(result.to_dict(), indent=2) if args.json else result.summary())
    return 0 if result.passed else 1


def _cmd_judge_prompt(args: argparse.Namespace) -> int:
    task = load_task(args.task)
    print(build_judge_prompt(task, Path(args.answer).read_text()))
    return 0


def _cmd_validate(args: argparse.Namespace) -> int:
    """Check that references score 1.0 and negative answers do not."""
    tasks = [load_task(p) for p in args.tasks] if args.tasks else discover_tasks()
    failures = 0
    for task in tasks:
        if task.answer_type == "rubric":
            print(f"skip  {task.id} (rubric: needs a judge)")
            continue
        ref = grade(task, task.reference_path.read_text())
        ok = ref.passed
        print(f"{'ok  ' if ok else 'FAIL'}  {task.id} reference score={ref.score:.3f}")
        if not ok:
            failures += 1
            print(ref.summary())
        for neg in task.negative_paths:
            res = grade(task, neg.read_text())
            bad = res.passed
            print(f"{'FAIL' if bad else 'ok  '}    negative {neg.name} score={res.score:.3f}")
            failures += bad
    return 1 if failures else 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="dataeng-bench")
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("list", help="list tasks")
    p.add_argument("--category")
    p.set_defaults(func=_cmd_list)

    p = sub.add_parser("show", help="print a task prompt")
    p.add_argument("task")
    p.set_defaults(func=_cmd_show)

    p = sub.add_parser("grade", help="grade an answer file")
    p.add_argument("task")
    p.add_argument("answer")
    p.add_argument("--judge-reply", help="judge model reply, for rubric tasks")
    p.add_argument("--json", action="store_true")
    p.set_defaults(func=_cmd_grade)

    p = sub.add_parser("judge-prompt", help="build the LLM-judge prompt for a rubric task")
    p.add_argument("task")
    p.add_argument("answer")
    p.set_defaults(func=_cmd_judge_prompt)

    p = sub.add_parser("validate", help="check reference and negative answers")
    p.add_argument("tasks", nargs="*")
    p.set_defaults(func=_cmd_validate)

    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
