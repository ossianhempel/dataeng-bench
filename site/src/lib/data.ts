// Build-time data loading: tasks from ../tasks, runs from ../runs.
import fs from "node:fs";
import path from "node:path";
import YAML from "yaml";

const REPO = path.resolve(process.cwd(), "..");
const TASKS_DIR = path.join(REPO, "tasks");
const RUNS_DIR = path.join(REPO, "runs");
export const REPO_URL = "https://github.com/ossianhempel/dataeng-bench";

// Drafts (published: false) show in `astro dev` and when INCLUDE_DRAFTS=1.
export const INCLUDE_DRAFTS = import.meta.env.DEV || process.env.INCLUDE_DRAFTS === "1";

export interface Source { title: string; url?: string; note?: string }
export interface Task {
  id: string; slug: string; title: string; category: string; subcategory: string;
  difficulty: "easy" | "medium" | "hard"; answer_type: "sql" | "structured" | "rubric";
  tags: string[]; sources: Source[]; prompt: string; relPath: string;
}
export interface Variant { id: string; label: string; model: string; provider: string; settings?: Record<string, unknown> }
export interface Result {
  variant: string; task_id: string; attempt?: number; score: number; passed: boolean;
  error?: string | null; input_tokens?: number; output_tokens?: number; cost_usd?: number; duration_s?: number;
}
export interface Run {
  schema_version: number; id: string; title: string; description?: string; created_at: string;
  published: boolean; sample?: boolean;
  benchmark: { version?: string; commit?: string; task_ids: string[] };
  settings?: Record<string, unknown>; variants: Variant[]; results: Result[];
}

function walk(dir: string): string[] {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const p = path.join(dir, e.name);
    return e.isDirectory() ? walk(p) : e.name === "task.yaml" ? [p] : [];
  });
}

let _tasks: Task[] | undefined;
export function getTasks(): Task[] {
  if (_tasks) return _tasks;
  _tasks = walk(TASKS_DIR)
    .map((file) => {
      const dir = path.dirname(file);
      const m = YAML.parse(fs.readFileSync(file, "utf8"));
      return {
        id: m.id, slug: m.id.replaceAll(".", "-").replaceAll("_", "-"), title: m.title,
        category: m.category, subcategory: m.subcategory ?? "", difficulty: m.difficulty,
        answer_type: m.answer_type, tags: m.tags ?? [], sources: m.sources ?? [],
        prompt: fs.readFileSync(path.join(dir, "prompt.md"), "utf8"),
        relPath: path.relative(REPO, dir),
      } as Task;
    })
    .sort((a, b) => a.id.localeCompare(b.id));
  return _tasks;
}

let _runs: Run[] | undefined;
export function getRuns(): Run[] {
  if (_runs) return _runs;
  const all = fs.existsSync(RUNS_DIR)
    ? fs.readdirSync(RUNS_DIR).filter((f) => f.endsWith(".json"))
        .map((f) => JSON.parse(fs.readFileSync(path.join(RUNS_DIR, f), "utf8")) as Run)
    : [];
  _runs = all
    .filter((r) => r.published || INCLUDE_DRAFTS)
    .sort((a, b) => b.created_at.localeCompare(a.created_at));
  return _runs;
}

export const latestPublishedRun = () => getRuns().find((r) => r.published);
export const taskById = (id: string) => getTasks().find((t) => t.id === id);
export const shortTaskName = (id: string) => id.split(".").at(-1)!.replaceAll("_", " ");

// ---- Scoring (see docs/results-format.md) ----

export interface VariantSummary {
  variant: Variant;
  overall: number;              // 0..100
  passRate: number;             // 0..100
  taskScores: Map<string, number>; // task id -> 0..1 (mean over attempts; missing = 0)
  attempts: number;
  cost?: number; outputTokens?: number;
  bySubcategory: Record<string, number>;
  byDifficulty: Record<string, number>;
  byAnswerType: Record<string, number>;
}

const mean = (xs: number[]) => (xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : 0);

function groupMean(taskIds: string[], scores: Map<string, number>, key: (t: Task) => string) {
  const groups: Record<string, number[]> = {};
  for (const id of taskIds) {
    const t = taskById(id);
    const k = t ? key(t) : "unknown";
    (groups[k] ??= []).push(scores.get(id) ?? 0);
  }
  return Object.fromEntries(Object.entries(groups).map(([k, v]) => [k, mean(v) * 100]));
}

export function summarize(run: Run): VariantSummary[] {
  const ids = run.benchmark.task_ids;
  return run.variants
    .map((variant) => {
      const rows = run.results.filter((r) => r.variant === variant.id);
      const taskScores = new Map<string, number>();
      for (const id of ids) taskScores.set(id, mean(rows.filter((r) => r.task_id === id).map((r) => r.score)));
      const costs = rows.map((r) => r.cost_usd).filter((c): c is number => c != null);
      const toks = rows.map((r) => r.output_tokens).filter((c): c is number => c != null);
      return {
        variant,
        overall: mean(ids.map((id) => taskScores.get(id) ?? 0)) * 100,
        passRate: rows.length ? (rows.filter((r) => r.passed).length / rows.length) * 100 : 0,
        taskScores,
        attempts: rows.length,
        cost: costs.length ? costs.reduce((a, b) => a + b, 0) : undefined,
        outputTokens: toks.length ? toks.reduce((a, b) => a + b, 0) : undefined,
        bySubcategory: groupMean(ids, taskScores, (t) => t.subcategory),
        byDifficulty: groupMean(ids, taskScores, (t) => t.difficulty),
        byAnswerType: groupMean(ids, taskScores, (t) => t.answer_type),
      };
    })
    .sort((a, b) => b.overall - a.overall);
}

// Color follows the model (variants of one model share a hue), assigned in the
// order models first appear in the run, never by rank.
export function modelSlots(run: Run): Map<string, number> {
  const slots = new Map<string, number>();
  for (const v of run.variants) if (!slots.has(v.model)) slots.set(v.model, slots.size + 1);
  return slots;
}

export const fmtDate = (iso: string) =>
  new Date(iso).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric", timeZone: "UTC" });
export const fmtScore = (x: number) => x.toFixed(1);
