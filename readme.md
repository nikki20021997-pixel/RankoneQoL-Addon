# RankoneQoL – The Ultimate Modular Quality of Life Addon

**RankoneQoL** is a highly optimized, modular Quality of Life addon built specifically for the modernized **Mists of Pandaria Classic** client (running on the modern Dragonflight retail engine). It combines essential automation tools, custom display widgets, an uncompressed sound database, and a highly customizable all-in-one inventory into a single, lightweight package.

***

## 🎒 Core Feature: The Advanced All-In-One Bag & Currency System

Your inventory is now completely transformed into a single, cohesive frame, bypassing standard Blizzard container constraints with advanced live features:

*   **Unified One-Bag Fusion**: Suppresses individual Blizzard bag frames entirely. Pressing `B` or clicking the interface bag bar seamlessly opens a gorgeous dark-theme total inventory window with full loot audio feedback.
*   **C++ Sub-Parent Matrix**: Implements invisible bag mothers (`Sub-Frames`) to grant authentic server-level click rights. Drag & drop on empty spaces, right-clicking to use items (like your Hearthstone), and equipping gear work flawlessly.
*   **Fluid Live-Layout Engine**: Adds a dedicated **Tab 6 (Bags)** to your settings panel. Adjust your **Inventory Scale**, **Column Count (6 to 16 columns)**, and **Slot Spacing (0px to 12px)**. The visual layout and frame width recalculate instantly while the window remains wide open!
*   **Real-Time Backpack Currency Tracker**: Integrates a dynamic currency widget at the bottom-left of the bag frame. It mirrors Blizzard's "Show on Backpack" setting, utilizing absolute database ID mapping to display selected tokens (e.g., Justice or Valor points) with accurate, non-overlapping tooltips instantly.
*   **Smart Station Automation**: Fully automates opening and closing your inventory at the Bank, Auction House, or merchants (fully toggleable in the options menu).

***

## 💎 Equipment Tracking & Search Tools

*   **Smart Inventory Item Levels**: Equippable weapons and armor pieces from uncommon (green) quality and above display their exact item level directly in the top-left corner of the slot, color-coded by rarity. Profession materials, glyphs, and quest items are automatically ignored by a precise API filter.
*   **Character Window Real-Time Tracking**: Equipped items dynamically track armor swaps. Replacing gear (e.g., changing an Epic cloak for a Rare variant) instantly forces an on-screen update of item level numbers and item quality border rings inside the Character Frame.
*   **Real-Time Item Search**: Integrated search bar on top of the bag. Typing letters dims non-matching items instantly while your hits shine in full brightness.

***

## ⚙️ Automation Modules (`Feature.lua`)

Streamline your daily routines with lightweight, automated event triggers designed to keep you in the action:

*   **Auto Junk Vendor**: Instantly unloads grey item clutter into any merchant window, automatically tracking your earnings.
*   **Auto Repair**: Keeps your armor pristine by auto-repairing at equipped blacksmiths using your personal funds.
*   **Auto Quest Handler**: Skips unnecessary dialog clicking by automatically accepting and turning in available quests.
*   **Auto Cinematic Skip**: Instantly bypasses standard in-game cutscenes and cinematics.
*   **Smart Group Invite**: Auto-accepts or invites players to your party based on customizable whisper keyword triggers.
*   **Fast Auto Loot**: Optimizes item retrieval speeds natively.

***

## 🖼️ UI, Audio & Map Customization

Tailor your interface to your specific hardware setup and aesthetic preference through specialized standalone sub-modules:

*   **Displays & Counters (`Displays.lua`)**: Integrates high-performance screen elements tracking your real-time FPS/MS (Performance) and active Gold Session earnings.
*   **Sound Manager (`Audio.lua` & `Sounds.lua`)**: Unlocks a massive internal sound database (`SoundListe`) allowing you to pick your favorite sound ID and adjust the specific output audio channel (e.g., Master, Dialog, Effects).
*   **Graphics & Font Scaler (`Graphics.lua`)**: Customizes fine-border styling, adjusts the item level (iLvl) text size on character gear slots, and scales tooltips dynamically.
*   **World Map Enhancement (`Maps.lua`) & Minimap Quick-Anchor (`minimap.lua`)**: Displays coordinates, unlocks free map movement, automates map transparency while moving, and places a sleek, draggable minimap button.

***

## 🌍 Massive Localization Spectrum (`Localization.lua`)

RankoneQoL features an independent dictionary system (`RankoneQoL.L`) ensuring that all labels, checkboxes, slider values, and status text natively translate based on your language setup. Fully optimized for six major clients:

*   🇩🇪 **German** (`deDE`)
*   🇺🇸 / 🇬🇧 **English** (`enUS` / `enGB`)
*   🇫🇷 **French** (`frFR`)
*   🇪🇸 / 🇲🇽 **Spanish** (`esES` / `esMX`)
*   🇷🇺 **Russian** (`ruRU`)
*   🇨🇳 / 🇹🇼 **Chinese** (`zhCN` / `zhTW`)

***

## 💿 Installation & Package Notice

When downloading the archive, simply extract the file into your `World of Warcraft\_classic_\Interface\AddOns\` directory. The package automatically deploys two folder directories which are coupled via required dependencies:

1.  `RankoneQoL` (Core Engine, Modules & Options Frame)
2.  `RankoneQoL_Bags` (C++ Secure Slot Container)