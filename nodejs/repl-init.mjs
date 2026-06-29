// @allow-mutation -- Node owns util.inspect.defaultOptions and the live
// repl.context; seeding them is the documented API and has no fresh-object
// alternative, since the REPL reads its own context object.
// @allow-console -- this is an interactive REPL launcher; console is the REPL's
// own output channel and there is no project logger in a dotfiles repo.
//
// Custom Node.js REPL launcher. This is the closest thing Node has to Python's
// PYTHONSTARTUP: a `-r`/--require preload cannot inject names into the REPL
// evaluation scope, but a launcher that calls repl.start() and seeds
// repl.context can. Run it through the `jsr` shell alias. Plain `node` is
// untouched; the rich REPL is opt-in.
//
// Node builtins only, no dependencies. The pure seams (makeHelpers,
// applyInspectDefaults) are exported so they can be unit tested without
// opening a REPL; repl.start() runs only when this file is the entry point.
//
// repl: https://nodejs.org/api/repl.html
// util.inspect: https://nodejs.org/api/util.html

import repl from "node:repl";
import os from "node:os";
import path from "node:path";
import fs from "node:fs";
import util from "node:util";
import { pathToFileURL } from "node:url";

// Deeper, colorized object printing. This also affects console.log output.
export function applyInspectDefaults(target = util) {
  target.inspect.defaultOptions.depth = 6;
  target.inspect.defaultOptions.colors = true;
  return target.inspect.defaultOptions;
}

// Helpers and handy builtins dropped straight into the prompt scope. The logger
// is injectable so the inspect helper can be exercised in tests.
export function makeHelpers({ log = console.log } = {}) {
  return {
    os,
    path,
    fs,
    util,
    // inspect(value, opts?) prints with full depth and colors by default.
    inspect: (value, options = {}) =>
      log(util.inspect(value, { depth: null, colors: true, ...options })),
  };
}

export function startRepl() {
  applyInspectDefaults();

  const server = repl.start({
    prompt: "js> ",
    useColors: true,
    // Show eval results with the same rich inspector settings.
    writer: (value) => util.inspect(value, { depth: 6, colors: true }),
  });

  Object.assign(server.context, makeHelpers());

  const historyFile =
    process.env.NODE_REPL_HISTORY ||
    path.join(os.homedir(), ".node_repl_history");

  server.setupHistory(historyFile, (err) => {
    if (err) {
      console.error(`repl history disabled: ${err.message}`);
    }
  });

  return server;
}

// Open the REPL only when run directly (node repl-init.mjs), not when imported.
// import.meta.url is already symlink-resolved, so resolve argv[1] the same way;
// the jsr alias invokes this file through a symlink in ~/.config/node.
function invokedDirectly() {
  if (!process.argv[1]) {
    return false;
  }
  return import.meta.url === pathToFileURL(fs.realpathSync(process.argv[1])).href;
}

if (invokedDirectly()) {
  startRepl();
}
