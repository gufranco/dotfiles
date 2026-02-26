---
name: perf
description: Run load tests and benchmarks against HTTP endpoints using k6, wrk, hey, or ab. Use when you need to stress test an API, compare performance before/after a change, or validate throughput and latency targets.
---

Run load tests against HTTP endpoints and present results in a readable format. Auto-detects installed load testing tools and picks the best available one.

## When to use

- Before and after performance-sensitive changes, to compare results.
- When validating that an endpoint meets latency or throughput requirements.
- When investigating slow responses or timeout issues under load.
- When you need a quick benchmark of a local or staging endpoint.

## When NOT to use

- Against production endpoints without explicit user approval.
- For long-running soak tests. This skill is designed for quick benchmarks.
- When no HTTP endpoint is available to test.

## Arguments

This skill accepts arguments after `/perf`:

- A URL (required): the endpoint to test. e.g. `http://localhost:3000/api/users`.
- `-n <requests>`: total number of requests. Default: 1000.
- `-c <concurrency>`: concurrent connections. Default: 10.
- `-d <duration>`: test duration (e.g. `30s`, `1m`). Overrides `-n` for tools that support duration-based runs.
- `--method <METHOD>`: HTTP method. Default: GET.
- `--body <json>`: request body for POST/PUT/PATCH.
- `--header <key:value>`: add a custom header. Can be repeated.
- `--compare`: run twice and show a before/after comparison. Pauses between runs for the user to make changes.
- `--script <path>`: for k6, use a custom script instead of generating one.

## Steps

1. **Parse arguments.** Extract the URL, request count, concurrency, duration, method, body, headers, and flags. If no URL is provided, ask the user.
2. **Validate the target.** Make a single request to the URL to confirm it is reachable. If it fails, report the error and stop.
3. **Detect the load testing tool.** Check in order of preference:
   - `which k6`: preferred. Scriptable, detailed histograms, supports duration and stages.
   - `which wrk`: fast, low overhead, good for raw throughput testing.
   - `which hey`: simple, good output format, supports all HTTP methods.
   - `which ab`: Apache Bench, widely available, basic but functional.
   - If none are installed, list all four with install instructions and ask which one to install.
4. **Build the command** based on the detected tool:

   **k6:**
   - If `--script` was provided, use that script directly.
   - Otherwise, generate a temporary k6 script:
     ```javascript
     import http from 'k6/http';
     import { check, sleep } from 'k6';

     export const options = {
       vus: <concurrency>,
       duration: '<duration>',  // or iterations: <requests>
     };

     export default function () {
       const res = http.<method>('<url>', <body>, { headers: <headers> });
       check(res, { 'status is 2xx': (r) => r.status >= 200 && r.status < 300 });
       sleep(0.1);
     }
     ```
   - Run: `k6 run --summary-trend-stats="avg,min,med,max,p(90),p(95),p(99)" <script>`.

   **wrk:**
   - Build: `wrk -t<threads> -c<concurrency> -d<duration> <url>`.
   - Threads default to min(concurrency, CPU cores).
   - For POST/PUT with body, generate a Lua script for wrk.

   **hey:**
   - Build: `hey -n <requests> -c <concurrency> -m <method> -T "application/json" -d '<body>' <url>`.
   - Add `-H` for each custom header.

   **ab:**
   - Build: `ab -n <requests> -c <concurrency> -m <method> -T "application/json" -p <bodyfile> <url>`.
   - For POST with body, write the body to a temp file.

5. **Run the test.** Execute the command and capture the full output.
6. **Parse and present results.** Extract these metrics regardless of tool:

   | Metric | Description |
   |--------|-------------|
   | Total requests | How many completed |
   | Failed requests | Non-2xx responses or connection errors |
   | Requests/sec | Throughput |
   | Latency avg | Mean response time |
   | Latency p50 | Median |
   | Latency p95 | 95th percentile |
   | Latency p99 | 99th percentile |
   | Transfer rate | Data throughput |

   Present as a clean table. Flag any concerning numbers:
   - p99 > 1s: warn about tail latency.
   - Error rate > 1%: warn about failures.
   - Requests/sec below expected threshold if one was mentioned.

7. **Compare mode** (if `--compare` was passed):
   - Run the test once and store results.
   - Tell the user: "First run complete. Make your changes, then tell me when to run again."
   - Wait for the user's signal.
   - Run the same test again.
   - Present a side-by-side comparison with percentage changes for each metric.
   - Highlight improvements in green context and regressions in red context.

8. **Cleanup.** Remove any temporary script files created during the run.

## Rules

- Never run against production URLs without explicit user confirmation. If the URL looks like production (no `localhost`, no `staging`, no `127.0.0.1`, no common dev ports), ask first.
- Always validate the target is reachable before starting the load test.
- Always clean up temporary files.
- Never install tools without asking. If nothing is installed, present the options.
- Default to reasonable values (1000 requests, 10 concurrency) to avoid accidentally overloading a service.
- For k6 with duration mode, default to 30s if no duration or request count is specified.
- Show the exact command being run so the user can reproduce it manually.

## Related skills

- `/test` - Run the project's test suite before benchmarking.
- `/docker` - Start services needed for the benchmark.
- `/checks` - Verify CI passes after performance changes.
