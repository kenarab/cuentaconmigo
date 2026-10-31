//! Validation rules (contracts/vectors/validation.json). Port of TelegramaCore/Validation.swift.
use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

use crate::template::{FormTemplate, Severity};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct ValidationIssue {
    pub code: String,
    pub severity: Severity,
    pub path: String,
}

impl ValidationIssue {
    fn new(code: &str, severity: Severity, path: String) -> Self {
        Self { code: code.into(), severity, path }
    }
}

/// Plain values to validate, as in contracts/vectors/validation.json.
#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
pub struct ValidationInput {
    #[serde(default)]
    pub mesa: BTreeMap<String, Option<String>>,
    #[serde(default)]
    pub header: BTreeMap<String, Option<i64>>,
    #[serde(default)]
    pub cells: BTreeMap<String, BTreeMap<String, Option<i64>>>,
}

pub fn validate(input: &ValidationInput, template: &FormTemplate) -> Vec<ValidationIssue> {
    let mut issues = Vec::new();

    for field in &template.mesa_fields {
        let raw = input.mesa.get(&field.id).cloned().flatten().unwrap_or_default();
        if raw.trim().is_empty() {
            issues.push(ValidationIssue::new("missing_mesa", Severity::Error, format!("mesa.{}", field.id)));
        }
    }

    let mut header: BTreeMap<&str, i64> = BTreeMap::new();
    for field in &template.header_fields {
        let path = format!("header.{}", field.id);
        match input.header.get(&field.id).copied().flatten() {
            None => {
                if field.is_required() {
                    issues.push(ValidationIssue::new("missing_value", Severity::Error, path));
                }
            }
            Some(v) if v < 0 => issues.push(ValidationIssue::new("negative_value", Severity::Error, path)),
            Some(v) => {
                header.insert(field.id.as_str(), v);
            }
        }
    }

    if let (Some(rule), Some(&votantes), Some(&electores)) =
        (&template.rules.votantes_max_electores, header.get("votantes"), header.get("electores"))
    {
        if votantes > electores {
            issues.push(ValidationIssue::new("votantes_exceed_electores", rule.severity, "header.votantes".into()));
        }
    }

    for category in &template.categories {
        let mut complete = true;
        let mut sum = 0i64;
        for row in &template.rows {
            let path = format!("cells.{}.{}", category.id, row.id);
            match input.cells.get(&category.id).and_then(|c| c.get(&row.id)).copied().flatten() {
                None => {
                    issues.push(ValidationIssue::new("missing_value", Severity::Error, path));
                    complete = false;
                }
                Some(v) if v < 0 => {
                    issues.push(ValidationIssue::new("negative_value", Severity::Error, path));
                    complete = false;
                }
                Some(v) => sum += v,
            }
        }
        // The total is only meaningful when every cell is present and valid.
        if let (true, Some(rule), Some(&votantes)) =
            (complete, &template.rules.category_total_equals_votantes, header.get("votantes"))
        {
            if sum != votantes {
                issues.push(ValidationIssue::new(
                    "category_total_mismatch",
                    rule.severity,
                    format!("cells.{}", category.id),
                ));
            }
        }
    }
    issues
}
