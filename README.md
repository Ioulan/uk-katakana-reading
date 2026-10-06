# Ultimate Kana: Katakana Reading (Practice)

This project is a modified version of [Katakana Reading Practice](https://ankiweb.net/shared/info/2015522924), enhanced with images, tts, etc.

A version-controlled Anki deck exported via CrowdAnki for learning Japanese Katakana words,
loanwords (外来語, *gairaigo*), and Japanese-made English (和製英語, *wasei-eigo*).

---

## Getting Started

Welcome!

### 1. Install CrowdAnki

In order to install and later upgrade Ultimate Kana without losing review history, install the CrowdAnki add-on:

1. Open Anki on your computer.
2. Go to the **Tools** menu and select **Add-ons** `(Ctrl+Shift+A)`.
3. Click **Get Add-ons...** and paste the code:
   ```
   1788670778
   ```
4. Click **OK** to install the add-on, then restart Anki.

### 2. Download the Deck

1. Open Anki and ensure your devices are synchronised.
2. Create a backup first via **File** -> **Create Backup** before proceeding, incase something goes wrong.
3. In the **File** menu, there's two option to Import from `CrowdAnki` do either:
   
   **CrowdAnki: Import from git repository** - Paste this repository URL and click OK
   ```sh
   https://github.com/Ioulan/uk-katakana-reading.git
   ``` 
   **OR**
   
   **CrowdAnki: Import from disk** - download or clone this repository to your computer:
   ```bash
   git clone https://github.com/Ioulan/uk-katakana-reading.git
   ```
   Browse and select for that folder (which contains `deck.json` and the `media/` dir)

4. Leave the CrowdAnki Import Settings dialog defaults as-is and press **OK** to start the import.
5. A dialog box will confirm once the import succeeds.

> To update, when a new version is released, simply re-import again via **CrowdAnki.

LATER:
Alternatively: Upload to AnkiWeb and add to GH Release: 
download and import the .apkg file from the releases page.
Add Screenshots

---

## Card Structure

Each card uses the `Katakana Reading` model with the following fields:

| Field | Description | Example |
|---|---|---|
| Katakana | Target word in Katakana | `ユーターン` |
| Meaning | English translation | `U-turn` |
| Origin | Etymology, abbr. or alt. spelling | `also 'Uターン'` |
| Notes | Usage notes or grammatical context | *(Optional)* |
| ImageDesc | Description tooltip for illustration | `矢印` |
| Image | HTML image tag pointing to local media | `<img src="...">` |
| Rōmaji | Modified Hepburn with macrons (hover preview) | `yūtān` |

---

## Script Usage (`script/add_romaji.rb`)

Run from the repository root:

```bash
# Populate missing Romaji fields across deck.json
ruby script/add_romaji.rb

# Preview changes without modifying files (dry run)
ruby script/add_romaji.rb --dry-run

# Force re-generation and overwrite existing Romaji fields
ruby script/add_romaji.rb --overwrite

# Specify a custom deck path
ruby script/add_romaji.rb path/to/deck.json
```

---

## Credits

- [Katakana Reading Practice](https://ankiweb.net/shared/info/2015522924)  shared deck on AnkiWeb.
- Images: Most illustrations used are from [Irasutoya](https://www.irasutoya.com/).
- Country Flags: are sourced from [Illustkun](https://illustkun.com/).
---


## Like my work? Buy me a coffee!
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N8K7285XXT)
