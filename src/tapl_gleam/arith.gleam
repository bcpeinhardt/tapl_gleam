import gleam/io
import gleam/result
import gleam/string
import tapl_gleam/arith/eval
import tapl_gleam/arith/lexer
import tapl_gleam/arith/parser
import tapl_gleam/arith/typechecker

pub type ProgramError {
  ScanError(lexer.ScanError)
  ParseError(parser.ParseError)
  TypeError(typechecker.TypeError)
  RuntimeError(eval.RuntimeError)
}

pub fn main() {
  let program = "if iszero pred succ 0 then false else true"

  case run_program(program) {
    Ok(#(val, type_)) ->
      io.println(eval.value_to_string(val) <> " : " <> string.inspect(type_))
    Error(e) -> io.print_error(string.inspect(e))
  }
}

fn run_program(
  src: String,
) -> Result(#(eval.Value, typechecker.ArithType), ProgramError) {
  use tokens <- result.try(lexer.scan(src) |> result.map_error(ScanError))
  use #(untyped_ast, _) <- result.try(
    parser.parse(tokens) |> result.map_error(ParseError),
  )
  use typed_ast <- result.try(
    typechecker.typecheck(untyped_ast) |> result.map_error(TypeError),
  )
  use value <- result.try(
    eval.eval(typed_ast) |> result.map_error(RuntimeError),
  )
  Ok(#(value, typed_ast.type_))
}
