import gleam/result
import tapl_gleam/arith/parser

pub type TypedTerm {
  Zero(type_: ArithType)
  TrueC(type_: ArithType)
  FalseC(type_: ArithType)
  Succ(type_: ArithType, term: TypedTerm)
  Pred(type_: ArithType, term: TypedTerm)
  IsZero(type_: ArithType, term: TypedTerm)
  Conditional(
    type_: ArithType,
    predicate: TypedTerm,
    then_branch: TypedTerm,
    else_branch: TypedTerm,
  )
}

pub type ArithType {
  NaturalNumber
  Boolean
}

pub type TypeError {
  TypeError
}

pub fn typecheck(term: parser.UntypedTerm) -> Result(TypedTerm, TypeError) {
  case term {
    parser.TrueC -> Ok(TrueC(type_: Boolean))
    parser.FalseC -> Ok(FalseC(type_: Boolean))
    parser.Zero -> Ok(Zero(type_: NaturalNumber))
    parser.Succ(t) -> {
      use typed_inner_term <- result.try(typecheck(t))
      case typed_inner_term.type_ {
        NaturalNumber -> Ok(Succ(type_: NaturalNumber, term: typed_inner_term))
        _ -> Error(TypeError)
      }
    }
    parser.Pred(t) -> {
      use typed_inner_term <- result.try(typecheck(t))
      case typed_inner_term.type_ {
        NaturalNumber -> Ok(Pred(type_: NaturalNumber, term: typed_inner_term))
        _ -> Error(TypeError)
      }
    }
    parser.IsZero(t) -> {
      use typed_inner_term <- result.try(typecheck(t))
      case typed_inner_term.type_ {
        NaturalNumber -> Ok(IsZero(type_: Boolean, term: typed_inner_term))
        _ -> Error(TypeError)
      }
    }
    parser.Conditional(p, lhs, rhs) -> {
      use typed_predicate <- result.try(typecheck(p))
      use typed_lhs <- result.try(typecheck(lhs))
      use typed_rhs <- result.try(typecheck(rhs))
      case
        typed_predicate.type_ == Boolean && typed_lhs.type_ == typed_rhs.type_
      {
        True ->
          Ok(Conditional(
            type_: typed_lhs.type_,
            predicate: typed_predicate,
            then_branch: typed_lhs,
            else_branch: typed_rhs,
          ))
        False -> Error(TypeError)
      }
    }
  }
}
