//// Gleam implementation of the arith language from TAPL

// The grammar (BNF-ish)
// t := terms (aka expressions)
// true
// false
// if t then t else t
// 0
// succ t
// pred t
// iszero t

// Example programs
// 
// if false then 0 else succ(0);
// => 1
// 
// iszero pred succ 0;
// => true

import gleam/list
import gleam/string

pub type ScanError {
  ScanError
}

pub type Token {
  Zero
  Succ
  Pred
  IsZero
  If
  Then
  Else
  TrueT
  FalseT
}

pub fn scan(src: String) -> Result(List(Token), ScanError) {
  do_scan(src |> string.split(" "), [])
}

fn do_scan(
  src: List(String),
  acc: List(Token),
) -> Result(List(Token), ScanError) {
  case src {
    [] -> Ok(acc |> list.reverse)
    ["0", ..rest] -> do_scan(rest, [Zero, ..acc])
    ["succ", ..rest] -> do_scan(rest, [Succ, ..acc])
    ["pred", ..rest] -> do_scan(rest, [Pred, ..acc])
    ["iszero", ..rest] -> do_scan(rest, [IsZero, ..acc])
    ["if", ..rest] -> do_scan(rest, [If, ..acc])
    ["then", ..rest] -> do_scan(rest, [Then, ..acc])
    ["else", ..rest] -> do_scan(rest, [Else, ..acc])
    ["true", ..rest] -> do_scan(rest, [TrueT, ..acc])
    ["false", ..rest] -> do_scan(rest, [FalseT, ..acc])
    _ -> Error(ScanError)
  }
}
