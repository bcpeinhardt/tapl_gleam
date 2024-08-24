import gleam/result
import tapl_gleam/arith/lexer

pub type UntypedTerm {
  Zero
  TrueC
  FalseC
  Succ(UntypedTerm)
  Pred(UntypedTerm)
  IsZero(UntypedTerm)
  Conditional(
    predicate: UntypedTerm,
    then_branch: UntypedTerm,
    else_branch: UntypedTerm,
  )
}

pub type ParseError {
  ParseError
}

pub fn parse(
  tokens: List(lexer.Token),
) -> Result(#(UntypedTerm, List(lexer.Token)), ParseError) {
  case tokens {
    [lexer.Zero, ..rest] -> Ok(#(Zero, rest))
    [lexer.FalseT, ..rest] -> Ok(#(FalseC, rest))
    [lexer.TrueT, ..rest] -> Ok(#(TrueC, rest))
    [lexer.Succ, ..rest] -> {
      use #(expr, r) <- result.try(parse(rest))
      Ok(#(Succ(expr), r))
    }
    [lexer.Pred, ..rest] -> {
      use #(expr, r) <- result.try(parse(rest))
      Ok(#(Pred(expr), r))
    }
    [lexer.IsZero, ..rest] -> {
      use #(expr, r) <- result.try(parse(rest))
      Ok(#(IsZero(expr), r))
    }
    [lexer.If, ..rest] -> {
      use #(p, rest) <- result.try(parse(rest))
      use rest <- result.try(parse_then(rest))
      use #(lhs, rest) <- result.try(parse(rest))
      use rest <- result.try(parse_else(rest))
      use #(rhs, rest) <- result.try(parse(rest))
      Ok(#(Conditional(p, lhs, rhs), rest))
    }
    _ -> Error(ParseError)
  }
}

fn parse_then(tokens) {
  case tokens {
    [lexer.Then, ..rest] -> Ok(rest)
    _ -> Error(ParseError)
  }
}

fn parse_else(tokens) {
  case tokens {
    [lexer.Else, ..rest] -> Ok(rest)
    _ -> Error(ParseError)
  }
}
