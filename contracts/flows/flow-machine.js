/*
 * Reference interpreter for the statecharts in contracts/flows/*.json.
 * UMD, no dependencies. Semantics are documented (in Spanish) in
 * contracts/flows/README.md; this file is the executable version of them.
 *
 * Also ports the pure domain helpers the guards need, so one file can be
 * checked against every vector in contracts/vectors/:
 *   - validate(input, template)      <- ios/TelegramaCore/.../Validation.swift
 *   - normalizeDigits(text)          <- ios/TelegramaCore/.../DigitNormalizer.swift
 *   - computeMismatches(context, t)  <- minimal double entry (AS-5 a)
 *
 * The machine never runs effects: send() returns their names and the host
 * (SwiftUI, Compose, the HTML prototype) performs them.
 */
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.FlowMachine = factory();
  }
}(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';

  // ---------------------------------------------------------------- helpers
  function clone(value) {
    return value === undefined ? undefined : JSON.parse(JSON.stringify(value));
  }
  function isPlainObject(value) {
    return value !== null && typeof value === 'object' && !Array.isArray(value);
  }
  function isInt(value) {
    return typeof value === 'number' && Number.isInteger(value);
  }
  function isNonNegativeInt(value) {
    return isInt(value) && value >= 0;
  }
  function has(object, key) {
    return Object.prototype.hasOwnProperty.call(object, key);
  }
  function issue(code, severity, path) {
    return { code: code, severity: severity, path: path };
  }

  // ----------------------------------------------------- DigitNormalizer.swift
  var LOOK_ALIKES = { O: '0', o: '0', l: '1', I: '1', '|': '1', S: '5', B: '8' };

  function isAsciiDigit(ch) {
    return ch >= '0' && ch <= '9' && ch.length === 1;
  }

  /** Converts an OCR token to a non-negative integer, or null. */
  function normalizeDigits(text) {
    if (typeof text !== 'string') return null;
    var chars = Array.from(text).filter(function (ch) {
      return !/\s/.test(ch) && ch !== '.' && ch !== ',';
    });
    if (chars.length === 0 || chars.length > 9) return null;
    if (!chars.some(isAsciiDigit)) return null;
    var digits = '';
    for (var i = 0; i < chars.length; i++) {
      var ch = chars[i];
      if (isAsciiDigit(ch)) digits += ch;
      else if (has(LOOK_ALIKES, ch)) digits += LOOK_ALIKES[ch];
      else return null;
    }
    return parseInt(digits, 10);
  }

  // ---------------------------------------------------------- Validation.swift
  /**
   * input: { mesa: {id: string|null}, header: {id: int|null}, cells: {category: {row: int|null}} }
   * Returns [{code, severity, path}] compared as an unordered set.
   */
  function validate(input, template) {
    var issues = [];
    var mesa = (input && input.mesa) || {};
    var headerIn = (input && input.header) || {};
    var cells = (input && input.cells) || {};
    var rules = template.rules || {};

    (template.mesaFields || []).forEach(function (field) {
      var raw = mesa[field.id];
      if (raw == null || String(raw).trim() === '') {
        issues.push(issue('missing_mesa', 'error', 'mesa.' + field.id));
      }
    });

    var header = {};
    (template.headerFields || []).forEach(function (field) {
      var path = 'header.' + field.id;
      var value = headerIn[field.id];
      if (value == null) {
        if (field.required === true) issues.push(issue('missing_value', 'error', path));
        return;
      }
      if (value < 0) issues.push(issue('negative_value', 'error', path));
      else header[field.id] = value;
    });

    if (rules.votantesMaxElectores && isInt(header.votantes) && isInt(header.electores) &&
        header.votantes > header.electores) {
      issues.push(issue('votantes_exceed_electores', rules.votantesMaxElectores.severity, 'header.votantes'));
    }

    (template.categories || []).forEach(function (category) {
      var complete = true;
      var sum = 0;
      var byRow = cells[category.id] || {};
      (template.rows || []).forEach(function (row) {
        var path = 'cells.' + category.id + '.' + row.id;
        var value = byRow[row.id];
        if (value == null) {
          issues.push(issue('missing_value', 'error', path));
          complete = false;
          return;
        }
        if (value < 0) {
          issues.push(issue('negative_value', 'error', path));
          complete = false;
        } else {
          sum += value;
        }
      });
      // The total is only meaningful when every cell is present and valid.
      if (complete && rules.categoryTotalEqualsVotantes && isInt(header.votantes) && sum !== header.votantes) {
        issues.push(issue('category_total_mismatch', rules.categoryTotalEqualsVotantes.severity, 'cells.' + category.id));
      }
    });
    return issues;
  }

  // ------------------------------------------------------- context <-> values
  /** Strips origins: context {value, origin} entries -> plain validation input. */
  function plainValues(context) {
    var out = { mesa: {}, header: {}, cells: {} };
    Object.keys(context.mesa || {}).forEach(function (k) { out.mesa[k] = context.mesa[k]; });
    Object.keys(context.header || {}).forEach(function (k) { out.header[k] = context.header[k].value; });
    Object.keys(context.cells || {}).forEach(function (cat) {
      out.cells[cat] = {};
      Object.keys(context.cells[cat]).forEach(function (row) { out.cells[cat][row] = context.cells[cat][row].value; });
    });
    return out;
  }

  function validateContext(context, template) {
    return validate(plainValues(context), template);
  }

  var ORIGINS = ['manual', 'ocr-accepted'];

  /** A value entry in a setValues payload: int, null (clear) or {value, origin}. */
  function isValueEntry(entry) {
    if (entry === null || isInt(entry)) return true;
    if (!isPlainObject(entry)) return false;
    if (!(entry.value === null || isInt(entry.value))) return false;
    return entry.origin === undefined || ORIGINS.indexOf(entry.origin) >= 0;
  }
  function toStoredValue(entry) {
    if (entry === null) return null;
    if (isInt(entry)) return { value: entry, origin: 'manual' };
    if (entry.value === null) return null;
    return { value: entry.value, origin: entry.origin || 'manual' };
  }

  function validValuesPayload(payload, template) {
    if (!isPlainObject(payload)) return false;
    if (!has(payload, 'header') && !has(payload, 'cells')) return false;
    if (has(payload, 'header')) {
      if (!isPlainObject(payload.header)) return false;
      var okHeader = Object.keys(payload.header).every(function (id) {
        return template.headerFields.some(function (f) { return f.id === id; }) && isValueEntry(payload.header[id]);
      });
      if (!okHeader) return false;
    }
    if (has(payload, 'cells')) {
      if (!isPlainObject(payload.cells)) return false;
      var okCells = Object.keys(payload.cells).every(function (cat) {
        if (!template.categories.some(function (c) { return c.id === cat; })) return false;
        if (!isPlainObject(payload.cells[cat])) return false;
        return Object.keys(payload.cells[cat]).every(function (row) {
          return template.rows.some(function (r) { return r.id === row; }) && isValueEntry(payload.cells[cat][row]);
        });
      });
      if (!okCells) return false;
    }
    return true;
  }

  function validPages(pages) {
    return Array.isArray(pages) && pages.length > 0 && pages.every(function (page) {
      return isPlainObject(page) && typeof page.id === 'string' && page.id !== '';
    });
  }

  function validMesa(mesa) {
    return isPlainObject(mesa) && Object.keys(mesa).every(function (k) {
      return mesa[k] === null || typeof mesa[k] === 'string';
    });
  }

  // ------------------------------------------------ double entry (AS-5 a)
  /**
   * Minimal blind double entry: the second person types header.votantes and
   * the total of each category; both are compared with the first entry.
   * A category whose first entry is incomplete compares as null.
   */
  function computeMismatches(context, template) {
    var first = plainValues(context);
    var second = context.second || { votantes: null, totals: {} };
    var out = [];
    var v1 = isInt(first.header.votantes) ? first.header.votantes : null;
    var v2 = isInt(second.votantes) ? second.votantes : null;
    if (v1 !== v2) out.push({ path: 'header.votantes', first: v1, second: v2 });
    template.categories.forEach(function (cat) {
      var complete = true;
      var sum = 0;
      var byRow = first.cells[cat.id] || {};
      template.rows.forEach(function (row) {
        var v = byRow[row.id];
        if (!isInt(v)) complete = false; else sum += v;
      });
      var s1 = complete ? sum : null;
      var s2 = isInt((second.totals || {})[cat.id]) ? second.totals[cat.id] : null;
      if (s1 !== s2) out.push({ path: 'cells.' + cat.id, first: s1, second: s2 });
    });
    return out;
  }

  // ------------------------------------------------------------- guards
  // Signature: guard(context, payload, env) -> boolean. env = {template, flow}.
  var guards = {
    // payload shape
    payloadHasPresentation: function (c, p, env) {
      return isPlainObject(p) && typeof p.presentation === 'string' && has(env.flow.presentations || {}, p.presentation);
    },
    payloadDocumentTypeAllowed: function (c, p, env) {
      return isPlainObject(p) && env.template.documentTypes.indexOf(p.documentType) >= 0;
    },
    payloadHasMesa: function (c, p) { return isPlainObject(p) && validMesa(p.mesa); },
    payloadHasPages: function (c, p) { return isPlainObject(p) && validPages(p.pages); },
    payloadHasPageId: function (c, p) {
      return isPlainObject(p) && typeof p.id === 'string' && c.pages.some(function (pg) { return pg.id === p.id; });
    },
    payloadHasSample: function (c, p) {
      var s = isPlainObject(p) ? p.sample : null;
      return isPlainObject(s) && typeof s.id === 'string' && s.id !== '' && validMesa(s.mesa) && validPages(s.pages);
    },
    payloadHasValues: function (c, p, env) { return validValuesPayload(p, env.template); },
    payloadHasJustification: function (c, p) {
      return isPlainObject(p) && (p.justification === null || typeof p.justification === 'string');
    },
    payloadHasSecondValues: function (c, p, env) {
      if (!isPlainObject(p) || (!has(p, 'votantes') && !has(p, 'totals'))) return false;
      if (has(p, 'votantes') && !(p.votantes === null || isInt(p.votantes))) return false;
      if (has(p, 'totals')) {
        if (!isPlainObject(p.totals)) return false;
        return Object.keys(p.totals).every(function (cat) {
          return env.template.categories.some(function (x) { return x.id === cat; }) &&
            (p.totals[cat] === null || isInt(p.totals[cat]));
        });
      }
      return true;
    },
    // context
    documentTypeChosen: function (c) { return c.documentType != null; },
    mesaComplete: function (c, p, env) {
      return env.template.mesaFields.every(function (f) {
        return typeof c.mesa[f.id] === 'string' && c.mesa[f.id].trim() !== '';
      });
    },
    hasPages: function (c) { return c.pages.length > 0; },
    noErrors: function (c, p, env) {
      return !validateContext(c, env.template).some(function (i) { return i.severity === 'error'; });
    },
    noWarnings: function (c, p, env) {
      return !validateContext(c, env.template).some(function (i) { return i.severity === 'warning'; });
    },
    justificationGiven: function (c) {
      return typeof c.justification === 'string' && c.justification.trim().length >= 5;
    },
    doubleEntryPending: function (c) { return c.doubleEntry === 'pending'; },
    presentationSupportsDoubleEntry: function (c, p, env) {
      var pres = (env.flow.presentations || {})[c.presentation];
      return !!pres && pres.supportsDoubleEntry === true;
    },
    secondComplete: function (c, p, env) {
      var s = c.second;
      return !!s && isNonNegativeInt(s.votantes) && env.template.categories.every(function (cat) {
        return isNonNegativeInt((s.totals || {})[cat.id]);
      });
    },
    entriesMatch: function (c) { return c.second != null && c.mismatches.length === 0; }
  };

  // ------------------------------------------------------------ actions
  // Signature: action(context, payload, env) -> void. Pure: mutate the copy only.
  function mergeMesa(context, mesa) {
    Object.keys(mesa).forEach(function (k) {
      if (mesa[k] === null) delete context.mesa[k]; else context.mesa[k] = mesa[k];
    });
  }
  function appendPages(context, pages) {
    pages.forEach(function (page) {
      var exists = context.pages.some(function (pg) { return pg.id === page.id; });
      if (!exists) context.pages.push(clone(page));
    });
  }
  function clearSecond(context) {
    context.second = null;
    context.mismatches = [];
    context.doubleEntry = 'none';
  }

  var actions = {
    setPresentation: function (c, p) { c.presentation = p.presentation; },
    setDocumentType: function (c, p) { c.documentType = p.documentType; },
    setMesa: function (c, p) { mergeMesa(c, p.mesa); },
    appendPages: function (c, p) { appendPages(c, p.pages); },
    removePage: function (c, p) {
      c.pages = c.pages.filter(function (pg) { return pg.id !== p.id; });
    },
    useSample: function (c, p) {
      mergeMesa(c, p.sample.mesa);
      appendPages(c, p.sample.pages.map(function (pg) { return Object.assign({}, pg, { source: 'sample' }); }));
      c.sample = { id: p.sample.id, label: typeof p.sample.label === 'string' ? p.sample.label : p.sample.id };
    },
    setValues: function (c, p) {
      if (p.header) {
        Object.keys(p.header).forEach(function (id) {
          var stored = toStoredValue(p.header[id]);
          if (stored === null) delete c.header[id]; else c.header[id] = stored;
        });
      }
      if (p.cells) {
        Object.keys(p.cells).forEach(function (cat) {
          if (!c.cells[cat]) c.cells[cat] = {};
          Object.keys(p.cells[cat]).forEach(function (row) {
            var stored = toStoredValue(p.cells[cat][row]);
            if (stored === null) delete c.cells[cat][row]; else c.cells[cat][row] = stored;
          });
        });
      }
    },
    invalidateDoubleEntry: function (c) {
      // Editing the first entry after a match voids the match. A pending
      // comparison survives: compareAgain recomputes it.
      if (c.doubleEntry === 'matched') clearSecond(c);
    },
    setJustification: function (c, p) { c.justification = p.justification; },
    lock: function (c) { c.locked = true; },
    clearSecond: function (c) { clearSecond(c); },
    setSecondValues: function (c, p) {
      if (!c.second) c.second = { votantes: null, totals: {} };
      if (has(p, 'votantes')) c.second.votantes = p.votantes;
      if (p.totals) Object.keys(p.totals).forEach(function (cat) { c.second.totals[cat] = p.totals[cat]; });
    },
    computeMismatches: function (c, p, env) { c.mismatches = computeMismatches(c, env.template); },
    markDoubleEntryMatched: function (c) { c.doubleEntry = 'matched'; },
    markDoubleEntryPending: function (c) { c.doubleEntry = 'pending'; }
  };

  // ------------------------------------------------------ flow structure
  function nodeAt(flow, pathParts) {
    var node = flow;
    for (var i = 0; i < pathParts.length; i++) {
      if (!node.states || !has(node.states, pathParts[i])) {
        throw new Error('Unknown state "' + pathParts.slice(0, i + 1).join('.') + '"');
      }
      node = node.states[pathParts[i]];
    }
    return node;
  }

  /** Resolves a target to a leaf path, descending through `initial`. */
  function enterTarget(flow, target) {
    var parts = target.split('.');
    var node = nodeAt(flow, parts);
    while (node.states) {
      if (!node.initial || !has(node.states, node.initial)) {
        throw new Error('Compound state "' + parts.join('.') + '" has no valid initial');
      }
      parts.push(node.initial);
      node = node.states[node.initial];
    }
    return parts.join('.');
  }

  function candidatesOf(handlers) {
    return Array.isArray(handlers) ? handlers : [handlers];
  }

  function guardName(entry) {
    return entry.charAt(0) === '!' ? entry.slice(1) : entry;
  }

  function guardsPass(guardList, registry, context, payload, env) {
    return (guardList || []).every(function (entry) {
      var negate = entry.charAt(0) === '!';
      var fn = registry.guards[guardName(entry)];
      var result = !!fn(context, payload, env);
      return negate ? !result : result;
    });
  }

  /** Static checks: every target, guard, action and effect name must exist. */
  function checkFlow(flow, registry) {
    var problems = [];
    var knownEffects = flow.effects ? Object.keys(flow.effects) : null;
    function walk(node, path) {
      Object.keys(node.on || {}).forEach(function (event) {
        candidatesOf(node.on[event]).forEach(function (t) {
          var where = (path || '(root)') + '.on.' + event;
          if (t.target) {
            try { enterTarget(flow, t.target); } catch (e) { problems.push(where + ': ' + e.message); }
          }
          (t.guard || []).forEach(function (g) {
            if (!registry.guards[guardName(g)]) problems.push(where + ': unknown guard "' + g + '"');
          });
          (t.actions || []).forEach(function (a) {
            if (!registry.actions[a]) problems.push(where + ': unknown action "' + a + '"');
          });
          if (knownEffects) {
            (t.effects || []).forEach(function (e) {
              if (knownEffects.indexOf(e) < 0) problems.push(where + ': unknown effect "' + e + '"');
            });
          }
          if (!t.target && !(t.actions && t.actions.length) && !(t.effects && t.effects.length)) {
            problems.push(where + ': transition does nothing');
          }
        });
      });
      Object.keys(node.states || {}).forEach(function (id) {
        var child = node.states[id];
        if (child.states && !child.initial) problems.push((path ? path + '.' : '') + id + ': compound state without initial');
        walk(child, (path ? path + '.' : '') + id);
      });
    }
    if (!flow.states || !flow.initial) problems.push('flow needs states and initial');
    else {
      try { enterTarget(flow, flow.initial); } catch (e) { problems.push('initial: ' + e.message); }
      walk(flow, '');
    }
    return problems;
  }

  // ------------------------------------------------------------ machine
  /**
   * createMachine(flow, template, options?)
   *   options.presentation  'f1' | 'f2' | 'f3' (overrides flow.context.presentation)
   *   options.state / options.context   restore a snapshot
   *   options.guards / options.actions  extend or override the named registries
   */
  function createMachine(flow, template, options) {
    options = options || {};
    var registry = {
      guards: Object.assign({}, guards, options.guards || {}),
      actions: Object.assign({}, actions, options.actions || {})
    };
    var problems = checkFlow(flow, registry);
    if (problems.length) throw new Error('Invalid flow:\n' + problems.join('\n'));

    var env = { template: template, flow: flow };
    var state = options.state ? enterTarget(flow, options.state) : enterTarget(flow, flow.initial);
    var context = clone(options.context || flow.context || {});
    if (options.presentation) context.presentation = options.presentation;
    var history = [];

    function screenOf(path) {
      var parts = path.split('.');
      for (var depth = parts.length; depth >= 1; depth--) {
        var node = nodeAt(flow, parts.slice(0, depth));
        if (node.screen) return node.screen;
      }
      return null;
    }

    function send(type, payload) {
      var parts = state.split('.');
      var result = {
        event: type, payload: clone(payload === undefined ? null : payload), from: state,
        state: state, context: clone(context), effects: [], ignored: true, transition: null
      };
      for (var depth = parts.length; depth >= 0; depth--) {
        var source = parts.slice(0, depth);
        var node = nodeAt(flow, source);
        if (!node.on || !has(node.on, type)) continue;
        var candidates = candidatesOf(node.on[type]);
        for (var i = 0; i < candidates.length; i++) {
          var t = candidates[i];
          if (!guardsPass(t.guard, registry, context, payload, env)) continue;
          var next = clone(context);
          (t.actions || []).forEach(function (name) { registry.actions[name](next, payload, env); });
          var newState = t.target ? enterTarget(flow, t.target) : state;
          context = next;
          state = newState;
          result.state = newState;
          result.context = clone(context);
          result.effects = (t.effects || []).slice();
          result.ignored = false;
          result.transition = {
            source: source.join('.') || '(root)', index: i,
            guard: (t.guard || []).slice(), actions: (t.actions || []).slice(), target: t.target || null
          };
          history.push({ event: type, from: result.from, to: newState, effects: result.effects });
          machine.state = state;
          machine.context = clone(context);
          machine.screen = screenOf(state);
          return result;
        }
      }
      history.push({ event: type, from: result.from, to: state, effects: [], ignored: true });
      return result;
    }

    /** Events reachable from the current leaf, with their guard status. */
    function availableEvents(payloadByEvent) {
      payloadByEvent = payloadByEvent || {};
      var parts = state.split('.');
      var seen = {};
      var list = [];
      for (var depth = parts.length; depth >= 0; depth--) {
        var source = parts.slice(0, depth).join('.') || '(root)';
        var node = nodeAt(flow, parts.slice(0, depth));
        Object.keys(node.on || {}).forEach(function (type) {
          var cands = candidatesOf(node.on[type]);
          var needsPayload = cands.some(function (t) {
            return (t.guard || []).some(function (g) { return guardName(g).indexOf('payload') === 0; });
          });
          var enabled = cands.some(function (t) {
            return guardsPass(t.guard, registry, context, payloadByEvent[type], env);
          });
          var targets = cands.map(function (t) { return t.target || null; });
          if (!seen[type]) {
            seen[type] = { type: type, source: source, enabled: enabled, needsPayload: needsPayload, targets: targets };
            list.push(seen[type]);
          } else if (!seen[type].enabled && enabled) {
            // A parent handler can still accept the event when the child's guards fail.
            seen[type].enabled = true;
            seen[type].fallbackSource = source;
          }
        });
      }
      return list;
    }

    var machine = {
      flow: flow,
      template: template,
      state: state,
      context: clone(context),
      screen: screenOf(state),
      send: send,
      availableEvents: availableEvents,
      issues: function () { return validateContext(context, template); },
      values: function () { return plainValues(context); },
      snapshot: function () { return { state: state, context: clone(context) }; },
      history: function () { return history.slice(); }
    };
    return machine;
  }

  return {
    createMachine: createMachine,
    checkFlow: checkFlow,
    enterTarget: enterTarget,
    validate: validate,
    validateContext: validateContext,
    plainValues: plainValues,
    normalizeDigits: normalizeDigits,
    computeMismatches: computeMismatches,
    guards: guards,
    actions: actions
  };
}));
