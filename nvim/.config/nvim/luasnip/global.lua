local ls = require("luasnip")
-- some shorthands...

ls.add_snippets("all", {
  ls.parser.parse_snipmate(
    { trig = "aiii", snippetType = "autosnippet" },
    [[
      // ${1} AI!
    ]]
  ),
})
