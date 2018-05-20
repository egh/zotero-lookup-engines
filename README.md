# Zotero lookup engines

This repository contains the sources used to generate the Zotero
lookup engine defintions hosted at:

  http://egh.github.io/zotero-lookup-engines/
  
In the `gh-pages` branch, it also includes the generated HTML files
that host the above site.

## How to build

- `ruby build.rb`
- `git checkout gh-pages`
- `mv generated/* .`
- `git commit`
- `git push`
