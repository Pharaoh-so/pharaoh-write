import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const checker = join(root, "skills", "anti-ai-filter", "check.mjs");

const prose =
  "Start with the request that reaches the server. A one-line log can tell you if the server saw it. The log still cannot tell you what the user clicked. Ask for the smallest example with the same failure. Keep the request ID beside the example.";

function check(t, format, draft, args = []) {
  const dir = mkdtempSync(join(tmpdir(), "founder-feature-test-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const file = join(dir, "draft.md");
  writeFileSync(file, draft);
  const run = spawnSync(process.execPath, [checker, file, "--format", format, ...args], {
    encoding: "utf8",
  });
  assert.ifError(run.error);
  return run;
}

test("founder-feature accepts clear technical cadence without weakening blog-post", (t) => {
  const founder = check(t, "founder-feature", prose);
  assert.equal(founder.status, 0, founder.stdout + founder.stderr);
  assert.match(founder.stdout, /RHYTHM: WARN/);
  assert.match(founder.stdout, /100%/);

  const blog = check(t, "blog-post", prose);
  assert.equal(blog.status, 1, blog.stdout + blog.stderr);
  assert.match(blog.stdout, /RHYTHM: FAIL/);
  assert.match(blog.stdout, /casing: 100%/);
});

test("founder-feature provides casing feedback without imposing a quota", (t) => {
  const result = check(t, "founder-feature", prose.toLowerCase());
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.match(result.stdout, /WARN: outside advisory technical sentence-case target/);
});

test("founder-feature retains non-cadence checks", (t) => {
  const result = check(t, "founder-feature", "One — two — three.");
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.match(result.stdout, /em-dashes: 2/);
});

test("the installer discovers the command without touching a real home", (t) => {
  const home = mkdtempSync(join(tmpdir(), "founder-feature-home-"));
  t.after(() => rmSync(home, { recursive: true, force: true }));
  const run = spawnSync("bash", [join(root, "install.sh"), "--dry-run"], {
    encoding: "utf8",
    env: { ...process.env, HOME: home },
  });
  assert.ifError(run.error);
  assert.equal(run.status, 0, run.stdout + run.stderr);
  assert.match(run.stdout, /\.claude\/commands\/founder-feature\.md/);
  assert.match(run.stdout, /\.claude\/commands\/write\.md/);
  const command = readFileSync(join(root, "commands", "founder-feature.md"), "utf8");
  assert.match(command, /writer-agent/);
  assert.match(command, /Mode: `founder-feature`/);
});
