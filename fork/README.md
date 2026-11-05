# The integration branch

This fork carries changes that are needed before, or instead of, an upstream release.
This folder exists only on the `integration` branch and never goes upstream.

## Branches

- `master` mirrors AvaloniaUI/AvaloniaEdit `master` and nothing else: `git fetch upstream`, then fast-forward.
- One topic branch per change, cut from upstream `master`, doing one thing. Topic branches that suit everyone go
  upstream as a pull request; the rest stay here. Either way the branch stays clean enough to propose later.
- `integration` is upstream `master` with every topic branch merged in (`git merge --no-ff <topic>`). It is never a
  pull request, so its merge commits don't matter.

| Topic branch | What | Upstream |
| --- | --- | --- |
| `search-panel-results` | `SearchPanel.SearchResults` and `SearchResultsChanged` | [AvaloniaUI/AvaloniaEdit#624](https://github.com/AvaloniaUI/AvaloniaEdit/pull/624) |
| `undo-continue-after-save` | `MarkAsOriginalFile` keeps an undo boundary (not merged here yet) | [AvaloniaUI/AvaloniaEdit#625](https://github.com/AvaloniaUI/AvaloniaEdit/pull/625) |
| `line-commands` | `MoveLinesUp`, `MoveLinesDown`, `DuplicateLines` (not merged here yet) | [AvaloniaUI/AvaloniaEdit#626](https://github.com/AvaloniaUI/AvaloniaEdit/pull/626) |

## Keeping it current

- Upstream moved: `git fetch upstream`, fast-forward `master`, then `git merge upstream/master` into `integration`.
- A topic branch changed: merge it into `integration` again.
- Upstream merged one of the pull requests: it comes in with upstream `master`; if review changed it, take
  upstream's version in the conflict. Then delete the topic branch and its row above.

## Packing

```
./fork/pack.ps1 -Output <folder feed>
```

This packs `Avalonia.AvaloniaEdit <next version>-fork.<commit count>` into the given folder, for an application to
restore from (map `Avalonia.AvaloniaEdit` to that folder in its `NuGet.config`). Going back to the official package
later is just a version change there.
