local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

ls.add_snippets("rust", {
  ls.parser.parse_snipmate(
    { trig = "ifn", snippetType = "autosnippet" },
    [[
    |${1:_}|{
      $0
    }
    ]]
  ),
  ls.parser.parse_snipmate(
    { trig = "asfn", snippetType = "autosnippet" },
    [[
  ${1:pub} async fn ${2:name}(${3:args}) -> ${4:ReturnType} {
    $0
    }
  ]]
  ),
  -- tokio test
  ls.parser.parse_snipmate(
    { trig = "tokiotest", snippetType = "autosnippet" },
    [[
    #[tokio::test]
    async fn ${1:test_name}() {
        $0
    }
    ]]
  ),
})
