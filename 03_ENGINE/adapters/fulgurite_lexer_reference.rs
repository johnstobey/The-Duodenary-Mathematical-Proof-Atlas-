// FULGURITE LEXER -- The 31-Glyph Tokenizer
// Janus Patulcius (The Opener) -- The Physics Face
//
// Tokenizes Tobey's astrological alphabet:
//    12 Signs (positions on Z/12Z)
//    10 Planets (operands -- the dynamics)
//     7 Aspects (operators -- maps to AspectOp)
//     2 Nodes (mathematical lines through infinity)
//    --
//    31 total glyphs
//
// TWO input modes -- NO ENGLISH:
//    1. Unicode glyphs (canonical)
//    2. Base-12 shorthand (compact)
//
// NO ASCII ENGLISH NAMES. The Fulgurite face does not speak English.
// English is the Obsidian face. Fulgurite speaks mathematics.
//
// Base-12 encoding (from TOBEY_CIPHER_STRUCTURES.md):
//    Signs:    0-9, A, B      (0=Aries..9=Capricorn, A=Aquarius, B=Pisces)
//    Aspects: C-I              (C=Conjunction, D=SemiSextile, E=Sextile,
//                               F=Square, G=Trine, H=Quincunx, I=Opposition)

use crate::labyrinth::AspectOp;

// ============================================================================
// TOKEN TYPE
// ============================================================================

#[derive(Debug, Clone, PartialEq)]
pub enum FulguritToken {
/// One of 12 zodiac signs (0=Aries..11=Pisces)
Sign(usize),
/// One of 10 planets (0=Sun..9=Pluto)
Planet(usize),
/// One of 7 aspects (maps directly to AspectOp)
Aspect(AspectOp),
/// North Node (ascending, future-oriented recursion entry)
NorthNode,
/// South Node (descending, past-oriented recursion exit)
SouthNode,
/// Base-12 subscript position (0-11)
Subscript(usize),
/// House context marker (1-12)
House(usize),
/// End of input
Eof,
}

// ============================================================================
// GLYPH TABLES -- The only alphabet Fulgurite recognizes
// ============================================================================

/// Unicode sign glyphs: U+2648 through U+2653
const SIGN_GLYPHS: [char; 12] = [
'\u{2648}', // ? Aries
'\u{2649}', // ? Taurus
'\u{264A}', // ? Gemini
'\u{264B}', // ? Cancer
'\u{264C}', // ? Leo
'\u{264D}', // ? Virgo
'\u{264E}', // ? Libra
'\u{264F}', // ? Scorpio
'\u{2650}', // ? Sagittarius
'\u{2651}', // ? Capricorn
'\u{2652}', // ? Aquarius
'\u{2653}', // ? Pisces
];

/// Unicode planet glyphs
const PLANET_GLYPHS: [char; 10] = [
'\u{2609}', // ? Sun
'\u{263D}', // ? Moon
'\u{263F}', // ? Mercury
'\u{2640}', // ? Venus
'\u{2642}', // ? Mars
'\u{2643}', // ? Jupiter
'\u{2644}', // ? Saturn
'\u{2645}', // ? Uranus
'\u{2646}', // ? Neptune
'\u{2647}', // ? Pluto
];

/// Unicode aspect glyphs
const ASPECT_GLYPHS: [(char, AspectOp); 7] = [
('\u{260C}', AspectOp::Conjunction),   // ?
('\u{26BA}', AspectOp::SemiSextile),   // ?
('\u{26B9}', AspectOp::Sextile),       // ?
('\u{25A1}', AspectOp::Square),        // [ ]
('\u{25B3}', AspectOp::Trine),         // ?
('\u{26BB}', AspectOp::Quincunx),      // ?
('\u{260D}', AspectOp::Opposition),    // ?
];

/// North/South node glyphs
const NORTH_NODE: char = '\u{260A}'; // ?
const SOUTH_NODE: char = '\u{260B}'; // ?

/// Unicode subscript digits
const SUBSCRIPT_DIGITS: [char; 10] = [
'\u{2080}', '\u{2081}', '\u{2082}', '\u{2083}', '\u{2084}',
'\u{2085}', '\u{2086}', '\u{2087}', '\u{2088}', '\u{2089}',
];

/// Circled numbers for house markers (?-?)
const HOUSE_MARKERS: [char; 12] = [
'\u{2460}', '\u{2461}', '\u{2462}', '\u{2463}', '\u{2464}', '\u{2465}',
'\u{2466}', '\u{2467}', '\u{2468}', '\u{2469}', '\u{246A}', '\u{246B}',
];

// ============================================================================
// BASE-12 SHORTHAND ENCODING
// ============================================================================

/// Map base-12 character to sign index (0-11)
/// 0-9 = signs 0-9, A/a = 10 (Aquarius), B/b = 11 (Pisces)
fn base12_to_sign(c: char) -> Option<usize> {
match c {
'0'..='9' => Some((c as u8 - b'0') as usize),
'A' | 'a' => Some(10),
'B' | 'b' => Some(11),
_ => None,
}
}

/// Map base-12 character to aspect
/// C=Conjunction, D=SemiSextile, E=Sextile, F=Square,
/// G=Trine, H=Quincunx, I=Opposition
fn base12_to_aspect(c: char) -> Option<AspectOp> {
match c.to_ascii_uppercase() {
'C' => Some(AspectOp::Conjunction),
'D' => Some(AspectOp::SemiSextile),
'E' => Some(AspectOp::Sextile),
'F' => Some(AspectOp::Square),
'G' => Some(AspectOp::Trine),
'H' => Some(AspectOp::Quincunx),
'I' => Some(AspectOp::Opposition),
_ => None,
}
}

// ============================================================================
// LEXER -- NO ENGLISH
// ============================================================================

pub struct FulguritLexer {
input: Vec<char>,
pos: usize,
}

impl FulguritLexer {
pub fn new(input: &str) -> Self {
FulguritLexer {
input: input.chars().collect(),
pos: 0,
}
}

fn current(&self) -> Option<char> {
self.input.get(self.pos).copied()
}

fn advance(&mut self) {
self.pos += 1;
}

fn peek(&self) -> Option<char> {
self.input.get(self.pos + 1).copied()
}

pub fn next_token(&mut self) -> FulguritToken {
// Skip whitespace and separators
while let Some(c) = self.current() {
if c.is_whitespace() || c == ',' || c == ';' {
self.advance();
} else {
break;
}
}

let c = match self.current() {
Some(c) => c,
None => return FulguritToken::Eof,
};

// 1. Check Unicode sign glyphs
for (idx, &glyph) in SIGN_GLYPHS.iter().enumerate() {
if c == glyph {
self.advance();
return FulguritToken::Sign(idx);
}
}

// 2. Check Unicode planet glyphs
for (idx, &glyph) in PLANET_GLYPHS.iter().enumerate() {
if c == glyph {
self.advance();
return FulguritToken::Planet(idx);
}
}

// 3. Check Unicode aspect glyphs
for &(glyph, ref aspect) in &ASPECT_GLYPHS {
if c == glyph {
self.advance();
return FulguritToken::Aspect(*aspect);
}
}

// 4. Check node glyphs
if c == NORTH_NODE {
self.advance();
return FulguritToken::NorthNode;
}
if c == SOUTH_NODE {
self.advance();
return FulguritToken::SouthNode;
}

// 5. Check Unicode subscript digits
for (idx, &sub) in SUBSCRIPT_DIGITS.iter().enumerate() {
if c == sub {
self.advance();
return FulguritToken::Subscript(idx);
}
}

// 6. Check circled number house markers
for (idx, &marker) in HOUSE_MARKERS.iter().enumerate() {
if c == marker {
self.advance();
return FulguritToken::House(idx + 1); // Houses are 1-indexed
}
}

// 7. Subscript notation: _N or _A or _B (non-English positional marker)
if c == '_' {
if let Some(next) = self.peek() {
if let Some(val) = base12_to_sign(next) {
self.advance(); // consume _
self.advance(); // consume digit
return FulguritToken::Subscript(val);
}
}
}

// 8. House marker: #N (non-English positional marker)
if c == '#' {
self.advance();
let mut num = String::new();
while let Some(d) = self.current() {
if d.is_ascii_digit() {
num.push(d);
self.advance();
} else {
break;
}
}
if let Ok(house) = num.parse::<usize>() {
if (1..=12).contains(&house) {
return FulguritToken::House(house);
}
}
return self.next_token();
}

// 9. Base-12 shorthand: single characters with mathematical meaning
//       Aspects: C-I (must check BEFORE signs to avoid ambiguity)
//       Signs: 0-9, A, B
//
//       The base-12 encoding is the compact form:
//       ?? [ ] ??    becomes   ?_7 F ?_A   in shorthand
//       Or fully compact: a pure position sequence like "7 F A"

// Check base-12 aspect (C-I) -- only if isolated (not part of longer alpha sequence)
if c.is_ascii_alphabetic() {
let upper = c.to_ascii_uppercase();
// Check if it's a base-12 aspect character
if let Some(aspect) = base12_to_aspect(upper) {
self.advance();
// Must be isolated: next char is not alphabetic
if self.current().map_or(true, |n| !n.is_ascii_alphabetic()) {
return FulguritToken::Aspect(aspect);
}
// Was part of a longer sequence -- back up
self.pos -= 1;
}
// Check if it's a base-12 sign (A or B only in alpha range)
if let Some(sign) = base12_to_sign(upper) {
if upper == 'A' || upper == 'B' {
self.advance();
if self.current().map_or(true, |n| !n.is_ascii_alphabetic()) {
return FulguritToken::Sign(sign);
}
self.pos -= 1;
}
}
// Unrecognized alphabetic -- skip entire word
// Fulgurite does not speak English. Skip it.
while let Some(ch) = self.current() {
if ch.is_ascii_alphabetic() {
self.advance();
} else {
break;
}
}
return self.next_token();
}

// Check base-12 sign digit (0-9)
if c.is_ascii_digit() {
if let Some(sign) = base12_to_sign(c) {
self.advance();
// Isolated digit = sign position
if self.current().map_or(true, |n| !n.is_ascii_alphabetic()) {
return FulguritToken::Sign(sign);
}
self.pos -= 1;
}
}

// Unknown character -- skip
self.advance();
self.next_token()
}

/// Tokenize the entire input, excluding Eof
pub fn tokenize(&mut self) -> Vec<FulguritToken> {
let mut tokens = Vec::new();
loop {
let tok = self.next_token();
if tok == FulguritToken::Eof {
break;
}
tokens.push(tok);
}
tokens
}
}

// ============================================================================
// TESTS -- ALL GLYPH AND BASE-12 ONLY. NO ENGLISH.
// ============================================================================

#[cfg(test)]
mod tests {
use super::*;

#[test]
fn test_sign_glyphs() {
// All 12 sign glyphs: ????????????
let input = "\u{2648}\u{2649}\u{264A}\u{264B}\u{264C}\u{264D}\u{264E}\u{264F}\u{2650}\u{2651}\u{2652}\u{2653}";
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 12);
for (i, tok) in tokens.iter().enumerate() {
assert_eq!(*tok, FulguritToken::Sign(i), "Sign {} failed", i);
}
}

#[test]
fn test_planet_glyphs() {
// ? ? ? ? ?
let input = "\u{2609} \u{263D} \u{263F} \u{2640} \u{2642}";
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 5);
assert_eq!(tokens[0], FulguritToken::Planet(0)); // ? Sun
assert_eq!(tokens[1], FulguritToken::Planet(1)); // ? Moon
assert_eq!(tokens[2], FulguritToken::Planet(2)); // ? Mercury
assert_eq!(tokens[3], FulguritToken::Planet(3)); // ? Venus
assert_eq!(tokens[4], FulguritToken::Planet(4)); // ? Mars
}

#[test]
fn test_aspect_glyphs() {
let input = "\u{25A1}"; // [ ] = Square
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 1);
assert_eq!(tokens[0], FulguritToken::Aspect(AspectOp::Square));
}

#[test]
fn test_all_seven_aspect_glyphs() {
// ? ? ? [ ] ? ? ?
let input = "\u{260C} \u{26BA} \u{26B9} \u{25A1} \u{25B3} \u{26BB} \u{260D}";
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 7);
assert_eq!(tokens[0], FulguritToken::Aspect(AspectOp::Conjunction));
assert_eq!(tokens[1], FulguritToken::Aspect(AspectOp::SemiSextile));
assert_eq!(tokens[2], FulguritToken::Aspect(AspectOp::Sextile));
assert_eq!(tokens[3], FulguritToken::Aspect(AspectOp::Square));
assert_eq!(tokens[4], FulguritToken::Aspect(AspectOp::Trine));
assert_eq!(tokens[5], FulguritToken::Aspect(AspectOp::Quincunx));
assert_eq!(tokens[6], FulguritToken::Aspect(AspectOp::Opposition));
}

#[test]
fn test_node_glyphs() {
let input = "\u{260A} \u{260B}"; // ? ?
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 2);
assert_eq!(tokens[0], FulguritToken::NorthNode);
assert_eq!(tokens[1], FulguritToken::SouthNode);
}

#[test]
fn test_base12_aspects() {
// C=Conjunction, D=SemiSextile, E=Sextile, F=Square,
// G=Trine, H=Quincunx, I=Opposition
let mut lex = FulguritLexer::new("F G I C");
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 4);
assert_eq!(tokens[0], FulguritToken::Aspect(AspectOp::Square));
assert_eq!(tokens[1], FulguritToken::Aspect(AspectOp::Trine));
assert_eq!(tokens[2], FulguritToken::Aspect(AspectOp::Opposition));
assert_eq!(tokens[3], FulguritToken::Aspect(AspectOp::Conjunction));
}

#[test]
fn test_base12_signs() {
// A=Aquarius(10), B=Pisces(11)
let mut lex = FulguritLexer::new("A B");
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 2);
assert_eq!(tokens[0], FulguritToken::Sign(10));
assert_eq!(tokens[1], FulguritToken::Sign(11));
}

#[test]
fn test_subscript_notation() {
// ?_7 [ ] ?_A   -- Mars at Scorpio, Square, Saturn at Aquarius
let input = "\u{2642}_7 \u{25A1} \u{2644}_A";
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 5);
assert_eq!(tokens[0], FulguritToken::Planet(4));          // ? Mars
assert_eq!(tokens[1], FulguritToken::Subscript(7));        // _7 Scorpio
assert_eq!(tokens[2], FulguritToken::Aspect(AspectOp::Square)); // [ ]
assert_eq!(tokens[3], FulguritToken::Planet(6));          // ? Saturn
assert_eq!(tokens[4], FulguritToken::Subscript(10));       // _A Aquarius
}

#[test]
fn test_house_marker() {
// ?_7 #10 -- Mars at Scorpio in 10th house
let input = "\u{2642}_7 #10";
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 3);
assert_eq!(tokens[0], FulguritToken::Planet(4));
assert_eq!(tokens[1], FulguritToken::Subscript(7));
assert_eq!(tokens[2], FulguritToken::House(10));
}

#[test]
fn test_full_equation_glyphs() {
// ?? ? ??   -- Sun at Leo, Conjunction, Moon at Cancer
let input = "\u{2609}\u{2084} \u{260C} \u{263D}\u{2083}";
let mut lex = FulguritLexer::new(input);
let tokens = lex.tokenize();
assert_eq!(tokens.len(), 5);
assert_eq!(tokens[0], FulguritToken::Planet(0));          // ? Sun
assert_eq!(tokens[1], FulguritToken::Subscript(4));        // ? Leo
assert_eq!(tokens[2], FulguritToken::Aspect(AspectOp::Conjunction)); // ?
assert_eq!(tokens[3], FulguritToken::Planet(1));          // ? Moon
assert_eq!(tokens[4], FulguritToken::Subscript(3));        // ? Cancer
}

#[test]
fn test_english_is_ignored() {
// English words are NOT valid Fulgurite -- they get skipped
let mut lex = FulguritLexer::new("mars square saturn");
let tokens = lex.tokenize();
// All three English words should be skipped -- empty result
assert_eq!(tokens.len(), 0,
"English words must be ignored by Fulgurite lexer, got {:?}", tokens);
}

#[test]
fn test_empty_input() {
let mut lex = FulguritLexer::new("");
let tokens = lex.tokenize();
assert!(tokens.is_empty());
}
}

