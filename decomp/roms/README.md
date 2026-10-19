# Local ROM images

These files are gitignored. Place them here yourself. The hashes are the No-Intro dumps checked when this repository was created.

| File | Original name | Size | SHA-1 |
| --- | --- | --- | --- |
| `magination.gbc` | `Magi Nation (USA).gbc` | 2,097,152 | `9972a7bca43210b4b6c0b3f6ee5d1957a865e12d` |
| `keepers-quest.gbc` | `Magi-Nation - Keeper's Quest (USA) (Proto).gbc` | 1,048,576 | `7c6b427810be2f0d7496ccb5eff2226d3ed1194e` |

`magination.gbc` is the retail Game Boy Color game. The build reads it with `INCBIN` and `make compare` checks the result against it. The hash of that built image is `rom.sha1`.

`keepers-quest.gbc` is the later homebrew sequel. It is not linked or disassembled.

Check a file you added with `make info`.
