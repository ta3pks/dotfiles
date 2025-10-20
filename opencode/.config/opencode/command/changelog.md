create a changelog markdown file if not exists if exists check if there should be new entries if so update it

changelog format must be as follows:

- always use fancy emojis
- dates obtained from git commits must be headers and must be in the format of "YYYY-MM-DD"
- under each date changes obtained from git messages must be listed as list items
- at the end of each item in parentheses write authors name obtained from the git commits
- in case of prs with multiple authors check which commits are related to pr and use that particular author - for example there might be some formatting and dep update tasks done by someone ignore those-
- make sure that you use fancy emojis and that you use the same emoji for the same change type
- use sub titles such as fix, patch, feat, breaking, docs, chore etc before the changes
