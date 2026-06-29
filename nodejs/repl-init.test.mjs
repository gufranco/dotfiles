// Tests for the custom REPL launcher seams in repl-init.mjs.
// Run with: node --test nodejs/
//
// The launcher's repl.start() is guarded behind a main check, so importing the
// module here does not open a REPL. We test the pure helper seams instead.

import test from "node:test";
import assert from "node:assert/strict";

import { makeHelpers, applyInspectDefaults } from "./repl-init.mjs";

test("makeHelpers exposes the builtin helpers and an inspect function", () => {
  const helpers = makeHelpers();
  for (const key of ["os", "path", "fs", "util", "inspect"]) {
    assert.ok(key in helpers, `expected helper "${key}"`);
  }
  assert.equal(typeof helpers.inspect, "function");
});

test("applyInspectDefaults sets depth and colors on the given util", () => {
  const fakeUtil = { inspect: { defaultOptions: {} } };
  const result = applyInspectDefaults(fakeUtil);
  assert.equal(result.depth, 6);
  assert.equal(result.colors, true);
});

test("inspect helper formats the value through the injected logger", () => {
  let captured;
  const helpers = makeHelpers({ log: (line) => { captured = line; } });
  helpers.inspect({ a: 1 });
  assert.match(captured, /a:/);
});
