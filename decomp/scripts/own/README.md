# scripts/own: data generators

Each script turns one family of data into editable source and back, and is
checked on every stream of its kind (AGENTS.md A1). The worker
(`scripts/worker.py`) does code, small tables and symbol propagation; these
do the assets.

- `gen_music.py`, `music_format.py`, `music-format.md`: songs (banks $32-$3C)
- `gen_sound_data.py`, `gen_wave_frames.py`: sound engine tables and waves
- `gen_palettes.py`: RGB555 palettes with the `rgb` macro
- `gen_sprite_lists.py`, `gen_script_lists.py`, `gen_map_sources.py`: record lists
- `rle_gfx.py`, `rlelib.py`: UnpackBytes-packed graphics, repacked in the build
- `check_fragments.py`: the W5 fragment check (pre-commit hook, check_rules.py)
- `bank_survey.py`, `remaining_survey.py`, `bank-survey.md`: what family each
  remaining bank holds, the starting point for the next codec
