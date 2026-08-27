# Deferred: adding rules/art/sound/ai to the file hash list

Reverted out of the `add-replays` branch. Keep this note until the change lands on its own.

## What was reverted

`package/Resources/FHCConfig.ini`, `[FilenameList]`:

```ini
09=expandmd01.mix
10=rulesmd.ini
11=artmd.ini
12=soundmd.ini
13=aimd.ini
```

## What it actually is

Not a replay-driven addition. `[FilenameList]` **replaces** the client's built-in defaults rather
than extending them — `FileHashCalculator.ReadFileNamesToCheck` falls back to
`DefaultFileNamesToCheck` only when the section is empty. This package sets `ClientGameType=Ares`,
whose built-in list is:

```
Ares.dll, Ares.dll.inj, Ares.mix, Syringe.exe, cncnet5.dll,
rulesmd.ini, artmd.ini, soundmd.ini, aimd.ini, shroud.shp
```

The package's own `[FilenameList]` contains none of those five INIs. So overriding the defaults
silently dropped them, and the multiplayer compatibility hash has not been covering loose
`rulesmd.ini` / `artmd.ini` / `soundmd.ini` / `aimd.ini` for as long as that override has existed.
Re-adding them restores coverage the package lost; it is an anti-cheat fix, not a replay feature.

## Impact is not what it looks like

`FileHashes.AddHashForFileIfExists` contributes nothing when a file is absent, so a name that is
not on disk does not move the hash at all. That splits the five entries in two:

| Entry | On a stock install | Effect on the MP hash |
|---|---|---|
| `rulesmd.ini`, `artmd.ini`, `soundmd.ini`, `aimd.ini` | absent — they live inside the mixes | **none.** Only players who have dropped a loose override in get a changed hash, which is the entire point |
| `expandmd01.mix` | **present**, ~4.8 MB stock file | **changes for everyone.** Every player's hash moves the moment this ships |

So the four INIs are safe to add at any time and break nothing. `expandmd01.mix` is the single
entry that forces a coordinated release.

## Recommendation

Land it in two pieces, neither of them in the replay PR:

1. **The four INIs, on their own, whenever convenient.** No hash change for anyone on a stock
   install, no lobby disruption, and it closes a real anti-cheat gap. It also improves replay
   mismatch detection for free, since `ReplayFileHashes` reads the same list.
2. **`expandmd01.mix` separately**, as a package release whose notes say the compatibility hash
   changed and everyone has to update. Worth doing — modified rules can be hidden inside a mix, so
   the coverage is real — but it needs the rollout coordinated.

Keeping it out of the replay branch is about reviewability, not risk: it is an anti-cheat change
and should be argued as one.

## Also worth checking when it lands

`ReplayFileHashes.Collect()` runs synchronously on the UI thread from `WriteSpawnIni` (every
recorded game) and from `ReplaysPanel.Launch()` (every playback). Measured cost of the current
tracked set is ~46 ms for 7.7 MB warm; adding `expandmd01.mix` roughly doubles the bytes. Still
well inside what the client already does uncached in the same code path —
`CnCNetGameLobby.StartGame` runs a full `CalculateHashes()` right before `WriteSpawnIni` — but
worth re-measuring rather than assuming.
