//! Public polling-place list for the cascading table pickers (F-16).
//! Source: data/establecimientos/nomina-2025.json (public, no personal data).
use serde::Deserialize;

#[derive(Debug, Clone, Deserialize)]
pub struct District {
    pub id: String,
    pub nombre: String,
    pub secciones: Vec<Section>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Section {
    pub id: String,
    pub nombre: String,
    pub locales: Vec<Place>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Place {
    pub codigo: String,
    pub nombre: String,
    pub direccion: String,
    pub localidad: String,
    /// `[first, last, circuito]` ranges.
    pub mesas: Vec<(i64, i64, String)>,
}

impl Place {
    pub fn tables(&self) -> Vec<(i64, String)> {
        self.mesas.iter().flat_map(|(a, b, c)| (*a..=*b).map(move |m| (m, c.clone()))).collect()
    }
    pub fn has_table(&self, mesa: i64) -> bool {
        self.mesas.iter().any(|(a, b, _)| (*a..=*b).contains(&mesa))
    }
}

#[derive(Debug, Deserialize)]
pub struct Nomina {
    pub distritos: Vec<District>,
}

fn fold(s: &str) -> String {
    s.chars()
        .map(|c| match c {
            'á' | 'Á' => 'a',
            'é' | 'É' => 'e',
            'í' | 'Í' => 'i',
            'ó' | 'Ó' => 'o',
            'ú' | 'Ú' | 'ü' | 'Ü' => 'u',
            'ñ' | 'Ñ' => 'n',
            other => other.to_ascii_lowercase(),
        })
        .collect()
}

impl Nomina {
    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }

    pub fn district(&self, id: &str) -> Option<&District> {
        self.distritos.iter().find(|d| d.id == id)
    }

    pub fn section(&self, district: &str, section: &str) -> Option<&Section> {
        self.district(district)?.secciones.iter().find(|s| s.id == section)
    }

    /// Places of a section whose name, address or locality contain every word of `query`
    /// (accent- and case-insensitive), or that hold the table number typed.
    pub fn search(&self, district: &str, section: &str, query: &str) -> Vec<&Place> {
        let Some(sec) = self.section(district, section) else { return vec![] };
        let words: Vec<String> = fold(query).split_whitespace().map(str::to_string).collect();
        let table: Option<i64> = query.trim().parse().ok();
        sec.locales
            .iter()
            .filter(|p| {
                if words.is_empty() {
                    return true;
                }
                if let Some(t) = table {
                    if p.has_table(t) {
                        return true;
                    }
                }
                let hay = fold(&format!("{} {} {}", p.nombre, p.direccion, p.localidad));
                words.iter().all(|w| hay.contains(w.as_str()))
            })
            .collect()
    }

    /// The place and circuit of a table, when the list knows it.
    pub fn locate(&self, district: &str, section: &str, mesa: i64) -> Option<(&Place, String)> {
        let sec = self.section(district, section)?;
        sec.locales.iter().find_map(|p| {
            p.mesas.iter().find(|(a, b, _)| (*a..=*b).contains(&mesa)).map(|(_, _, c)| (p, c.clone()))
        })
    }
}
