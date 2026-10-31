#!/usr/bin/env node
/*
 * Runs the shared contract vectors against the reference JS implementation:
 *   contracts/vectors/digits.json        -> normalizeDigits
 *   contracts/vectors/validation.json    -> validate (unordered set comparison)
 *   contracts/vectors/capture-flow.json  -> createMachine / send
 *
 * Usage: node contracts/flows/run-vectors.js [--verbose]
 * Exit code 1 when any case fails. No dependencies.
 */
'use strict';
const fs = require('fs');
const path = require('path');
const FlowMachine = require('./flow-machine.js');

const ROOT = path.resolve(__dirname, '..');
const verbose = process.argv.includes('--verbose');

function readJson(relative) {
  return JSON.parse(fs.readFileSync(path.join(ROOT, relative), 'utf8'));
}
function loadTemplate(id) {
  return readJson(path.join('templates', id + '.json'));
}
function deepEqual(a, b) {
  return JSON.stringify(a) === JSON.stringify(b);
}
/** Every key in `expected` must match `actual`; nested objects recurse, arrays compare exactly. */
function partialMatch(expected, actual) {
  if (expected !== null && typeof expected === 'object' && !Array.isArray(expected)) {
    if (actual === null || typeof actual !== 'object' || Array.isArray(actual)) return false;
    return Object.keys(expected).every((key) => partialMatch(expected[key], actual[key]));
  }
  return deepEqual(expected, actual);
}
function issueKey(issue) {
  return `${issue.code}|${issue.severity}|${issue.path}`;
}

const summary = [];
let failures = 0;

function report(file, name, ok, detail) {
  if (!ok) failures++;
  if (!ok || verbose) {
    console.log(`${ok ? 'PASS' : 'FAIL'}  ${file} :: ${name}`);
    if (!ok && detail) console.log('      ' + detail.split('\n').join('\n      '));
  }
}

// ---------------------------------------------------------------- digits
(function runDigits() {
  const file = 'vectors/digits.json';
  const data = readJson(file);
  let pass = 0;
  data.cases.forEach((c) => {
    const got = FlowMachine.normalizeDigits(c.input);
    const ok = got === c.expected;
    if (ok) pass++;
    report(file, JSON.stringify(c.input), ok, `expected ${JSON.stringify(c.expected)}, got ${JSON.stringify(got)}`);
  });
  summary.push([file, pass, data.cases.length]);
})();

// ------------------------------------------------------------ validation
(function runValidation() {
  const file = 'vectors/validation.json';
  const data = readJson(file);
  const template = loadTemplate(data.template);
  let pass = 0;
  data.cases.forEach((c) => {
    const got = FlowMachine.validate(c.input, template).map(issueKey).sort();
    const expected = c.expected.map(issueKey).sort();
    const ok = deepEqual(got, expected);
    if (ok) pass++;
    report(file, c.name, ok, `expected ${JSON.stringify(expected)}\ngot      ${JSON.stringify(got)}`);
  });
  summary.push([file, pass, data.cases.length]);
})();

// ---------------------------------------------------------- capture flow
(function runFlow() {
  const file = 'vectors/capture-flow.json';
  const data = readJson(file);
  const flow = readJson(path.join('flows', data.flow + '.flow.json'));
  const template = loadTemplate(data.template);
  const preludes = data.preludes || {};

  function expand(events, depth) {
    if (depth > 10) throw new Error('prelude nesting too deep');
    const out = [];
    events.forEach((e) => {
      if (e && typeof e === 'object' && e.prelude) {
        if (!preludes[e.prelude]) throw new Error(`unknown prelude "${e.prelude}"`);
        out.push(...expand(preludes[e.prelude], depth + 1));
      } else {
        out.push(typeof e === 'string' ? { type: e } : e);
      }
    });
    return out;
  }

  let pass = 0;
  data.cases.forEach((c) => {
    const problems = [];
    let last = null;
    let machine;
    try {
      machine = FlowMachine.createMachine(flow, template, { presentation: c.presentation });
      const events = expand((c.prelude ? [{ prelude: c.prelude }] : []).concat(c.events || []), 0);
      events.forEach((e) => { last = machine.send(e.type, e.payload); });
    } catch (err) {
      problems.push(`threw: ${err.message}`);
    }
    if (machine) {
      if (machine.state !== c.expectState) problems.push(`state: expected ${c.expectState}, got ${machine.state}`);
      const effects = last ? last.effects : [];
      if (!deepEqual(effects, c.expectEffects || [])) problems.push(`effects: expected ${JSON.stringify(c.expectEffects || [])}, got ${JSON.stringify(effects)}`);
      if (c.expectIgnored !== undefined) {
        const ignored = last ? last.ignored : false;
        if (ignored !== c.expectIgnored) problems.push(`ignored: expected ${c.expectIgnored}, got ${ignored}`);
      }
      if (c.expectContext && !partialMatch(c.expectContext, machine.context)) {
        problems.push(`context: expected ⊇ ${JSON.stringify(c.expectContext)}\n         got      ${JSON.stringify(machine.context)}`);
      }
    }
    const ok = problems.length === 0;
    if (ok) pass++;
    report(file, c.name, ok, problems.join('\n'));
  });
  summary.push([file, pass, data.cases.length]);
})();

// ---------------------------------------------------------------- summary
console.log('');
summary.forEach(([file, pass, total]) => {
  console.log(`${pass === total ? 'ok  ' : 'FAIL'} ${file}: ${pass}/${total}`);
});
const total = summary.reduce((n, s) => n + s[2], 0);
const passed = summary.reduce((n, s) => n + s[1], 0);
console.log(`${passed}/${total} vectors pass`);
process.exit(failures ? 1 : 0);
