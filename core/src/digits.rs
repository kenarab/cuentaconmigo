//! Converts an OCR token to a non-negative integer (contracts/vectors/digits.json).
//! Look-alike letters are only corrected when the token has at least one real digit.
//! Port of TelegramaCore/DigitNormalizer.swift.

fn look_alike(c: char) -> Option<char> {
    match c {
        'O' | 'o' => Some('0'),
        'l' | 'I' | '|' => Some('1'),
        'S' => Some('5'),
        'B' => Some('8'),
        _ => None,
    }
}

pub fn normalize(text: &str) -> Option<i64> {
    let token: Vec<char> = text.chars().filter(|c| !c.is_whitespace() && *c != '.' && *c != ',').collect();
    if token.is_empty() || token.len() > 9 || !token.iter().any(|c| c.is_ascii_digit()) {
        return None;
    }
    let mut digits = String::with_capacity(token.len());
    for c in token {
        if c.is_ascii_digit() {
            digits.push(c);
        } else {
            digits.push(look_alike(c)?);
        }
    }
    digits.parse().ok()
}
