function cli --wraps='cargo run --features cli -- ' --description 'alias cli=cargo run --features cli -- '
  cargo run --features cli --  $argv; 
end
