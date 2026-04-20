# Ticket Map Editor for Godot

A lightweight Godot tool for authoring Ticket-to-Ride-style maps, exporting map data, creating gameplay/config data, and exporting a final folder that is easy to copy into another project or runtime.

This project was built in **Godot 4.6.1 stable**.

---

## Table of Contents

- [What this tool does](#what-this-tool-does)
- [Who this is for](#who-this-is-for)
- [Install Godot](#install-godot)
- [Quick start](#quick-start)
- [Important concept: Tool code vs workspace](#important-concept-tool-code-vs-workspace)
- [Repository structure](#repository-structure)
- [Workspace structure](#workspace-structure)
- [Plugin setup](#plugin-setup)
- [How to create a new map](#how-to-create-a-new-map)
- [How to use the map editor](#how-to-use-the-map-editor)
- [Scene structure](#scene-structure)
- [Important Godot usage notes](#important-godot-usage-notes)
- [Key scenes and scripts](#key-scenes-and-scripts)
- [TicketMapEditor reference](#ticketmapeditor-reference)
- [NameSyncer reference](#namesyncer-reference)
- [CityNode reference](#citynode-reference)
- [RouteNode reference](#routenode-reference)
- [Map data resources](#map-data-resources)
- [Game config resources](#game-config-resources)
- [How to use the config editor plugin](#how-to-use-the-config-editor-plugin)
- [Destination ticket validation](#destination-ticket-validation)
- [Export workflow](#export-workflow)
- [Export format](#export-format)
- [Editing defaults for all instances](#editing-defaults-for-all-instances)
- [Recommended workflow summary](#recommended-workflow-summary)
- [AI Declaration](#ai-declaration)
- [License](#license)

---

## What this tool does

This tool lets you:

- author a board-style map using a reusable `TicketMapEditor` scene
- place `CityNode` scenes as city anchors
- place `RouteNode` scenes as route paths between cities
- use a blueprint image as a layout reference
- export map data as:
  - JSON
  - `TicketMapData` Godot resources
- create gameplay/config data through a Godot editor plugin
- assign:
  - trains per player
  - transport card counts
  - transport card images
  - destination ticket rows
  - destination ticket images
- validate destination ticket rows
- export a final folder that contains:
  - `config.json`
  - `img/`

This repository does **not** include proprietary Ticket to Ride artwork or map assets. Any example or test assets should be your own work or otherwise safe for redistribution.

---

## Who this is for

This project is intended for people who want to author map and config data visually, even if they are **not very experienced with Godot**.

You do **not** need to be a strong Godot user to use the tool, but it helps to understand a few basics:

- scenes
- nodes
- inherited scenes
- instancing child scenes
- moving nodes in the 2D editor

This README is written with that in mind.

---

## Install Godot

This tool was built in [Godot 4.6.1 stable](https://godotengine.org/download/archive/4.6.1-stable/).

You can download the latest Godot release from the [official download page](https://godotengine.org/download/).

If you are new to Godot, the official getting started guide is here:

- [Godot Getting Started](https://docs.godotengine.org/en/stable/getting_started/step_by_step/index.html)

---

## Quick start

If you want the shortest version:

1. Open the project in Godot.
2. Enable the plugin.
3. Open `ticket_map_editor/scenes/TicketMapEditor.tscn`.
4. Create an **inherited scene** from it.
5. Save that inherited scene into `workspace/maps/`.
6. Use that inherited scene as your editable map.
7. Add `CityNode` instances under `Cities`.
8. Add `RouteNode` instances under `Routes`.
9. Export `TicketMapData`.
10. Open the plugin tab.
11. Create or load a `TicketGameConfigData` resource.
12. Attach the exported `TicketMapData`.
13. Fill in trains, transport cards, destination tickets, and images.
14. Save the config resource.
15. Export the final pack.

---

## Important concept: Tool code vs workspace

This project is intentionally split into two ideas:

### Tool code
This is the reusable system itself.

Examples:
- `addons/ticket_map_editor/`
- `ticket_map_editor/`

### Workspace
This is where users actually do project work.

Examples:
- map scenes
- exported map resources
- config resources
- final export folders
- working images

In general:

- edit tool code only if you are changing the tool itself
- do actual authored content inside `workspace/`

---

## Repository structure

A simplified overview:

```text
res://
├── addons/
│   └── ticket_map_editor/
├── ticket_map_editor/
│   ├── core/
│   ├── scenes/
│   ├── ui/
│   ├── data/
│   └── helpers/
├── workspace/
│   ├── maps/
│   ├── map_data/
│   ├── config_data/
│   ├── exports/
│   └── img/
├── README.md
├── LICENSE
└── project.godot

### Main areas

#### `addons/ticket_map_editor/`
Contains the Godot plugin entry files.

#### `ticket_map_editor/`
Contains the reusable tool itself:
- scripts
- scenes
- row UIs
- resource definitions
- helper scripts

#### `workspace/`
Contains user-authored and exported content.

---

## Workspace structure

The intended use of each workspace folder:

### `workspace/maps/`
Put editable map scenes here.

These should generally be **inherited scenes** made from the base `TicketMapEditor.tscn`.

### `workspace/map_data/`
Put exported `TicketMapData` `.tres` resources here.

These are produced by the map editor and later consumed by the config editor.

### `workspace/config_data/`
Put saved `TicketGameConfigData` `.tres` resources here.

These are edited through the plugin.

### `workspace/exports/`
Put final exported packs here.

A final export folder typically contains:
- `config.json`
- `img/`

### `workspace/img/`
Put working images here, such as:
- blueprint images
- transport card images
- destination ticket images

---

## Plugin setup

The config editor is intended to be used through the Godot plugin tab.

### To enable the plugin

1. Open the project in Godot.
2. Go to **Project > Project Settings > Plugins**
3. Find the `Ticket Map Editor` plugin.
4. Enable it.

Once enabled, the plugin should appear as its own editor tab.

---

## How to create a new map

This is the recommended workflow.

### Step 1: Open the base map editor scene
Open:

- `ticket_map_editor/scenes/TicketMapEditor.tscn`

### Step 2: Create an inherited scene
Do **not** do your real work inside the base tool scene.

Instead:

- right click `TicketMapEditor.tscn`
- create an **Inherited Scene**
- save it into:

- `workspace/maps/`

For example:
- `workspace/maps/example_map_editor.tscn`
- `workspace/maps/my_map_editor.tscn`

This inherited scene is your actual map scene.

### Why use an inherited scene?
Because the base `TicketMapEditor.tscn` is part of the reusable tool.

An inherited scene lets you:
- keep the tool clean
- make your own maps safely
- update or replace your own authored scene independently

---

## How to use the map editor

Inside your inherited map scene, the important nodes are:

- `NameSyncer`
- `BackgroundSprite`
- `Cities`
- `Routes`

### Typical map workflow

1. Set `map_id`
2. Set `map_size`
3. Optionally assign a `background_texture`
4. Add `CityNode` instances under `Cities`
5. Add `RouteNode` instances under `Routes`
6. Assign each route’s `from_city` and `to_city`
7. Adjust route segment points
8. Optionally run the `NameSyncer`
9. Export the map as:
   - JSON
   - `TicketMapData`

### What the map editor exports

The map editor can export:

- a JSON representation of the map
- a `TicketMapData` `.tres` resource

The `TicketMapData` resource is the important intermediate step used by the config editor.

---

## Scene structure

A typical map editor scene looks like:

- `TicketMapEditor`
  - `NameSyncer`
  - `BackgroundSprite`
  - `Cities`
  - `Routes`

### Meaning of the nodes

#### `BackgroundSprite`
Used for an optional blueprint/reference image.

#### `Cities`
Container for all placed `CityNode` instances.

#### `Routes`
Container for all placed `RouteNode` instances.

#### `NameSyncer`
Convenience helper for syncing scene-tree names.

---

## Important Godot usage notes

If you are new to Godot:

### Use Instantiate Child Scene
When adding reusable scenes like `CityNode.tscn` or `RouteNode.tscn`, use:

- **Instantiate Child Scene**

This is commonly available from the scene toolbar and often mapped to:

- **Ctrl + Shift + A** on Windows

Do **not** create a plain child node if you intend to use the reusable scene.

### Edit defaults in the base scene
If you want to change the defaults for all future cities or routes:

- edit `ticket_map_editor/scenes/CityNode.tscn`
- edit `ticket_map_editor/scenes/RouteNode.tscn`

Do not only change one placed instance if your goal is to change the default behavior or visuals globally.

### Learn basic 2D editing
When working with the map editor, it helps to be comfortable with:
- selecting nodes
- moving nodes
- adjusting `Line2D` points for routes
- switching between select/move/edit actions in the 2D editor

### The plugin is for editing config data
The gameplay/config editor is intended to be used through the plugin tab, not as a normal runtime scene.

---

## Key scenes and scripts

### Main map editor
- `ticket_map_editor/scenes/TicketMapEditor.tscn`
- `ticket_map_editor/core/ticket_map_editor.gd`

### Name sync helper
- `ticket_map_editor/core/editor_name_sync.gd`

### Map authoring scenes
- `ticket_map_editor/scenes/CityNode.tscn`
- `ticket_map_editor/scenes/RouteNode.tscn`

### Config editor
- `addons/ticket_map_editor/ticket_game_config_editor.tscn`
- `ticket_map_editor/core/ticket_game_config_editor.gd`

### Row UI scenes
- `ticket_map_editor/scenes/transport_card_row.tscn`
- `ticket_map_editor/scenes/destination_ticket_row.tscn`

### Row UI scripts
- `ticket_map_editor/ui/transport_card_row.gd`
- `ticket_map_editor/ui/destination_ticket_row.gd`

### Resource definitions
Located under:
- `ticket_map_editor/data/`

### Helpers
Located under:
- `ticket_map_editor/helpers/`

---

## TicketMapEditor reference

`TicketMapEditor` is the root scene used to author a map.

Important exported variables include:

- `map_id`  
  Logical identifier for the map.

- `map_size`  
  Logical size of the map canvas.

- `show_map_bounds`  
  Shows the visible authored map rectangle.

- `bounds_color`
- `bounds_width`  
  Control the appearance of the map bounds rectangle.

- `background_texture`  
  Optional blueprint/reference image.

- `background_modulate`  
  Controls how visible the blueprint is.

- `fit_background_to_map_size`  
  Scales the blueprint to the logical map area.

- `normalize_to_positive_coordinates`  
  Shifts exported coordinates so negative values become non-negative.

- `export_json_path`  
  JSON export location.

- `export_map_data_resource_path`  
  `TicketMapData` `.tres` export location.

The scene exports map data and is the authoring entry point for maps.

---

## NameSyncer reference

`NameSyncer` is an editor convenience helper.

It can:
- rename city nodes from city display names
- rename route nodes from their connected cities
- resolve duplicates with numbered suffixes

This only affects scene-tree readability and workflow. It is not the core exported data itself.

---

## CityNode reference

`CityNode` represents a city anchor on the map.

Typical exported variables include:

- `city_id`  
  Stable ID used in export.

- `display_name`  
  Human-readable display name.

- `label_offset`  
  Controls label placement.

- label style exports  
  Control label appearance.

- marker style exports  
  Control circle radius, fill, outline, and appearance.

Cities export:
- ID
- display name
- position

---

## RouteNode reference

`RouteNode` represents a route between two cities.

Typical exported variables include:

- `from_city`, `to_city`  
  References to the connected city nodes.

- `route_length`  
  Number of interior segment points.

- `cart_type`  
  Logical transport card type / route color, exported as a string.

- `label_offset`  
  Route label placement.

- line style exports  
  Line appearance and snapping behavior.

- segment style exports  
  Segment rectangle visuals, outlines, arrows, and preview settings.

Routes export:
- source city ID
- destination city ID
- route length
- cart type
- full path points
- interior segment points
- per-segment rotation data

---

## Map data resources

The map editor produces intermediate Godot resources.

Important resource types include:

- `TicketMapData`
- `TicketCityData`
- `TicketRouteData`
- `TicketSegmentPointData`

These resources are intended to be:
- saved as `.tres`
- passed into the config editor
- used as a stable intermediate layer before final export

---

## Game config resources

The config editor uses resource types such as:

- `TicketGameConfigData`
- `TransportCardConfigData`
- `DestinationTicketConfigData`

These hold:
- trains per player
- transport card counts and images
- destination ticket rows and images
- the linked `TicketMapData`

---

## How to use the config editor plugin

The plugin is used to edit gameplay/config data.

### Typical workflow

1. Enable the plugin.
2. Open the plugin tab.
3. Load or create a `TicketGameConfigData` resource.
4. Make sure it references a `TicketMapData` resource.
5. Set trains per player.
6. Fill transport card counts.
7. Assign transport card images if desired.
8. Add destination ticket rows.
9. Assign points, start city, end city, and optional image.
10. Save the config resource.
11. Export the final folder.

### What the plugin screen manages

Top section:
- current config resource
- save path
- export folder
- linked source map
- trains per player
- main action buttons

Scrollable content:
- transport card rows
- destination ticket rows

---

## Destination ticket validation

Destination tickets are treated as **bidirectional**.

That means:
- `city_a -> city_b`
- `city_b -> city_a`

are treated as the same logical pair.

A destination ticket row will warn when:

- it points to the same city on both ends
- another enabled row has the same city combination in either direction

Disabled rows are ignored for this validation and also ignored during final export.

---

## Export workflow

There are three main export stages.

### 1. Map editor export
From the map editor, export:

- JSON map data if desired
- `TicketMapData` resource

Recommended location:
- `workspace/map_data/`

### 2. Config editor save
From the plugin, save:

- `TicketGameConfigData` resource

Recommended location:
- `workspace/config_data/`

### 3. Final handoff export
From the plugin, export a final folder containing:

- `config.json`
- `img/`

Recommended location:
- `workspace/exports/`

This final folder is intended to be easy to copy into another project or runtime.

---

## Export format

At a high level, the final `config.json` contains two major parts:

- `map`
- `game_config`

### `map` includes
- `map_id`
- `map_size`
- `normalized`
- `normalization_offset`
- `cities`
- `routes`

### `game_config` includes
- `trains_per_player`
- `transport_cards`
- `destination_tickets`

### Images
Images are copied into:
- `img/`

And the JSON stores relative paths such as:
- `img/transport_blue.png`
- `img/destination_01.png`

Shared source images are deduplicated so the same image file only needs to be exported once.

---

## Editing defaults for all instances

To change defaults globally for authored content:

- edit `ticket_map_editor/scenes/CityNode.tscn`
- edit `ticket_map_editor/scenes/RouteNode.tscn`

To change defaults for plugin row UI:
- edit `ticket_map_editor/scenes/transport_card_row.tscn`
- edit `ticket_map_editor/scenes/destination_ticket_row.tscn`

This is usually better than manually adjusting every placed instance.

---

## Recommended workflow summary

If you are unsure what to do, use this order:

1. Enable the plugin.
2. Create a new inherited map scene from `TicketMapEditor.tscn`.
3. Save that map scene into `workspace/maps/`.
4. Author the map.
5. Export `TicketMapData`.
6. Open the plugin.
7. Create or load a `TicketGameConfigData`.
8. Link the exported `TicketMapData`.
9. Fill in game config values.
10. Save the config resource.
11. Export the final pack.

---

## AI Declaration

This project was developed with partial assistance from OpenAI's ChatGPT, using the GPT-5.4 Thinking model.

The AI tool was used to support ideation, code generation, refactoring suggestions, implementation planning, and documentation drafting. Final responsibility for selecting, modifying, integrating, and validating the resulting work remained with the project author.

---

## License

This repository is released under the MIT License.
