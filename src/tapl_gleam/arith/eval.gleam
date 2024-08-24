import gleam/bool
import gleam/int
import gleam/result
import tapl_gleam/arith/typechecker

pub type Value {
  NumberV(Int)
  BoolV(Bool)
}

pub fn value_to_string(v: Value) -> String {
  case v {
    NumberV(n) -> int.to_string(n)
    BoolV(b) -> bool.to_string(b)
  }
}

pub type RuntimeError {
  RuntimeError
}

pub fn eval(program: typechecker.TypedTerm) -> Result(Value, RuntimeError) {
  case program {
    typechecker.Zero(_) -> Ok(NumberV(0))
    typechecker.TrueC(_) -> Ok(BoolV(True))
    typechecker.FalseC(_) -> Ok(BoolV(False))
    typechecker.Succ(_, t) -> {
      use inner <- result.try(eval(t))
      case inner {
        NumberV(n) -> Ok(NumberV(1 + n))
        _ -> Error(RuntimeError)
      }
    }
    typechecker.Pred(_, t) -> {
      use inner <- result.try(eval(t))
      case inner {
        NumberV(n) -> Ok(NumberV(int.max(0, n - 1)))
        _ -> Error(RuntimeError)
      }
    }
    typechecker.IsZero(_, t) -> {
      use inner <- result.try(eval(t))
      case inner {
        NumberV(n) -> Ok(BoolV(n == 0))
        _ -> Error(RuntimeError)
      }
    }
    typechecker.Conditional(_, predicate, lhs, rhs) -> {
      use p <- result.try(eval(predicate))
      case p {
        BoolV(True) -> eval(lhs)
        BoolV(False) -> eval(rhs)
        _ -> Error(RuntimeError)
      }
    }
  }
}
