# 🐉 Monsters Compendium

![Lua](https://img.shields.io/badge/Lua-5.1%2B-2C2D72?logo=lua&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-single%20file-003B57?logo=sqlite&logoColor=white)
![No JavaScript](https://img.shields.io/badge/JavaScript-none-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Status](https://img.shields.io/badge/status-work%20in%20progress-orange)

A compendium of **monsters and spells for Dungeons & Dragons 1st Edition**, built to be
searched quickly behind the GM screen and to be **shared safely with other game masters**.

> 🚧 **Work in progress.** The data layer and the configuration are done; interface needs
> work. See the [roadmap](#-roadmap) for exactly where things stand.

---

## 📖 Why this project is changing

The first version of this project was a REST API running in Docker, with PostgreSQL,
OpenResty and Lapis. It worked on my machine, but it was the wrong shape for
**handing to someone else**:

| Problem in the first version | What it means for other people | What replaces it |
|---|---|---|
| 🐳 Needs Docker, Compose and three services | A GM has to be a sysadmin to open a bestiary | One program, one file |
| 🔑 Default `postgres` / `postgres` password in the repo | Anyone who starts it as-is has a guessable password | No database server, no password |
| 🌐 API published on all network interfaces | Anyone on the same Wi-Fi could add or delete monsters | Listens on `127.0.0.1` only |
| 🐞 `development` mode with full error pages | Errors could leak internal paths | Generic errors; details go to a log file |
| 🗂️ Data stored inside the project folder | Updating the program could wipe a campaign | Data lives in the user's own data folder |

So I am moving everything to a form that can be **downloaded and opened**, and I am
treating security as part of the design, not as something to add at the end.

## 🧭 How it works

```
Put both .lua files in the same folder, type "lua5.5 main.lua"
```

## 🧰 Stack

| | Piece | What it does |
|---|---|---|
| 🌙 | **Lua** | The whole program. Developed on Lua 5.5; written to run on 5.1+ (older versions not tested yet) |
| 🗄️ | **SQLite** (`lsqlite3complete`) | The database, as one file. SQLite is bundled, so nothing to install on the system |
| 🎨 | **LWTK** | Lua GUI library. I'm starting to figure out how it works and it's pretty good. |

**Removed:** Lapis, OpenResty, PostgreSQL, Docker, Nginx.
## 🗺️ Roadmap

**Foundation**
- [x] 🗄️ `db.lua` – SQLite data layer, schema migrations, prepared statements
- [x] ⚙️ `main.lua` – Call all functions from the Database; also adds filters and show things.
- [x] ⚙️ `dark_theme.lua` – Testing layout styling capabilities.
- [ ] 📄 `LICENSE` (MIT) and dependency list (`.rockspec`)
- [ ] 🧪 `tests/db_test.lua` – tests for the data layer, using an in-memory database

**Monsters**
- [ ] 📥 I'll try to export the monsters in a PDF file, but I don't know how, yet. I have
          to study different Lua stuff. 
- [x] 📜 Stat block page (it's on the right of the interface)
- [ ] ➕ Add monster form, with safe delete (confirmation popup)

**Distribution**
- [ ] 📦 Lua files and need to install LWTK
- [ ] 🏷️ There are file "mergers" out there, for Lua. I'll try something.
- [ ] 🎲 There's also file builders for different OS. I'll try these too. 

✅ done  🚧 in progress or planned

## ⚖️ Game content and licensing

- The code is released under the **MIT License**.
- The program ships with an **empty database**. Monsternstatistics from published
  D&D books are copyrighted, so add your own entries or use content under an open license.
- *Dungeons & Dragons* is a trademark of Wizards of the Coast. This project is an independent
  fan tool and is not affiliated with or endorsed by them.

## 🤝 The Changes

Initially when I posted this I was thinking about making some kind of API, use ports, write routes and whatnot. 
And then I realized we don't need this stuff with LWTK and SQLite. I hope you enjoy it anyways...

## 🙏 Built with

[Lua](https://www.lua.org/) · 
[SQLite](https://www.sqlite.org/) · 
[lwtk](https://github.com/lwtk/lwtk)
