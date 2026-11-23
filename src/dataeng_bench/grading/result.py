from __future__ import annotations

from dataclasses import asdict, dataclass, field


@dataclass
class CheckResult:
    name: str
    passed: bool
    weight: float = 1.0
    message: str = ""
    # Points earned for partially credited checks (rubric criteria). Defaults
    # to all-or-nothing.
    earned: float | None = None

    @property
    def points(self) -> float:
        if self.earned is not None:
            return self.earned
        return self.weight if self.passed else 0.0


@dataclass
class GradeResult:
    task_id: str
    checks: list[CheckResult] = field(default_factory=list)
    error: str | None = None

    @property
    def score(self) -> float:
        """Weighted share of points earned, from 0 to 1."""
        if self.error:
            return 0.0
        total = sum(c.weight for c in self.checks)
        if total == 0:
            return 0.0
        return sum(c.points for c in self.checks) / total

    @property
    def passed(self) -> bool:
        """True only when every check passed in full."""
        return self.error is None and bool(self.checks) and all(c.passed for c in self.checks)

    def to_dict(self) -> dict:
        data = asdict(self)
        data["score"] = round(self.score, 4)
        data["passed"] = self.passed
        return data

    def summary(self) -> str:
        lines = [f"{self.task_id}: score={self.score:.3f} passed={self.passed}"]
        if self.error:
            lines.append(f"  ERROR: {self.error}")
        for c in self.checks:
            mark = "PASS" if c.passed else "FAIL"
            line = f"  [{mark}] {c.name} ({c.points:g}/{c.weight:g})"
            if c.message and not c.passed:
                line += f"\n         {c.message}"
            lines.append(line)
        return "\n".join(lines)
