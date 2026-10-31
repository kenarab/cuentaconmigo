//! Declarative form definition (contracts/templates). Replacing the template must not
//! require code changes.
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Severity {
    Error,
    Warning,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum DocumentType {
    Telegrama,
    Acta,
    Certificado,
}

impl DocumentType {
    pub fn label(self) -> &'static str {
        match self {
            DocumentType::Telegrama => "Telegrama",
            DocumentType::Acta => "Acta de escrutinio",
            DocumentType::Certificado => "Certificado de escrutinio",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Field {
    pub id: String,
    pub label: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub required: Option<bool>,
}

impl Field {
    pub fn is_required(&self) -> bool {
        self.required.unwrap_or(true)
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Category {
    pub id: String,
    pub label: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Row {
    pub id: String,
    pub label: String,
    pub kind: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Rule {
    pub severity: Severity,
}

#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Rules {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub votantes_max_electores: Option<Rule>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub category_total_equals_votantes: Option<Rule>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FormTemplate {
    pub id: String,
    pub version: u32,
    pub fictitious: bool,
    pub title: String,
    pub document_types: Vec<DocumentType>,
    pub mesa_fields: Vec<Field>,
    pub header_fields: Vec<Field>,
    pub categories: Vec<Category>,
    pub rows: Vec<Row>,
    pub rules: Rules,
}

impl FormTemplate {
    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }
}
