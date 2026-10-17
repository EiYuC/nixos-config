Put your custom 小鹤音形 Rime source files here: *.schema.yaml, *.dict.yaml,
Lua modules (if used), and default.custom.yaml selecting your actual schema_id.
Do not add build/, installation.yaml, user dictionaries or private runtime data.

Files are linked individually into ~/.local/share/fcitx5/rime. The runtime
folder stays writable. Once a *.schema.yaml is present, the managed Fcitx5
profile selects Rime by default. After activation use Fcitx5's Rime Deploy
menu. Until your custom data is added, Pinyin remains the default.
