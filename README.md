# Ticket Map Editor for Godot

A lightweight Godot tool for authoring Ticket-to-Ride-style maps and exporting the authored data to JSON for use in other runtimes.

This project was built in **Godot 4.6.1 stable**.

## What this tool does

- lets you author a map in Godot using a `TicketMapEditor` scene
- lets you place `CityNode` scenes as city anchors
- lets you place `RouteNode` scenes as route paths between cities
- supports blueprint/background images for map layout reference
- exports the authored map to JSON
- includes a name-sync helper for keeping node names readable and consistent

You do **not** need to understand Godot well to use this tool.

This repository does **not** include any proprietary Ticket to Ride artwork or map assets. Any example blueprint assets should be original placeholders created for testing.

## Install Godot

This tool was built in [Godot 4.6.1 stable](https://godotengine.org/download/archive/4.6.1-stable/).

Download the Latest Godot from the official download pages: [official download page](https://godotengine.org/download/).

If you are new to Godot, and are interested in learning it now, the official getting started documentation is [here](https://docs.godotengine.org/en/stable/getting_started/step_by_step/index.html)

## Repository layout

Keep the tool scripts and scenes together in one folder in your Godot project.

Typical files:

- `TicketMapEditor.tscn`
- `ticket_map_editor.gd`
- `CityNode.tscn`
- `city_node.gd`
- `RouteNode.tscn`
- `route_node.gd`
- `NameSyncer` scene child script
- `cart_types.gd`

## Quick start

1. Open the project in Godot.
2. Open `TicketMapEditor.tscn`, or create a new scene using the same structure.
3. Add city instances under the `Cities` Node2D.
4. Add route instances under the `Routes` Node2D.
5. Assign each route’s `from_city` and `to_city`.
6. Adjust route points in the editor.
7. Optionally run the `NameSyncer` tool button.
8. Export the map to JSON from the editor tool button ("Export Map JSON") within TicketMapEditor.

You can also create a completely new map by duplicating or recreating a `TicketMapEditor` scene and building a new level there.

## Scene structure

A typical editor scene looks like:

- `TicketMapEditor`
  - `NameSyncer`
  - `BackgroundSprite`
  - `Cities`
  - `Routes`

`Cities` holds `CityNode` instances.  
`Routes` holds `RouteNode` instances.

## Important Godot usage notes

If you are new to Godot:

- To add a reusable scene like `CityNode.tscn` or `RouteNode.tscn`, use **Instantiate Child Scene** rather than creating a plain child node. In the editor this is commonly opened with **Ctrl+Shift+A** on windows (it is the clip looking thing on the top left).
- If you want to change the defaults for all cities or all routes, open and edit the base `CityNode.tscn` or `RouteNode.tscn` scene directly instead of only editing one instance.
- Node names in the scene tree can be synchronized with the `NameSyncer` helper.
- When trying to move the City Nodes, Route Nodes and route segments (the points of the Line2D) around, getting familiar with the Select Mode and Move Mode of your mouse is useful.

## Core scenes and scripts

### `TicketMapEditor`

This is the root scene used to author a map.

Key exported variables:

- `map_id`  
  Logical identifier for the exported map.

- `map_size`  
  The authored/exported size of the map canvas.

- `show_map_bounds`  
  Shows the editor rectangle for the logical map size.

- `bounds_color`, `bounds_width`  
  Controls the visible map-bounds rectangle.

- `background_texture`  
  Optional blueprint/reference image for layout.

- `background_modulate`  
  Controls blueprint visibility.

- `fit_background_to_map_size`  
  Scales the blueprint to the authored map rectangle.

- `normalize_to_positive_coordinates`  
  Shifts exported coordinates so negative values become non-negative.

- `export_json_path`  
  Output file path for the exported JSON.

The export button writes a JSON file containing map metadata, cities, and routes.

### `NameSyncer`

This helper node updates scene-tree node names from authored content.

Typical use:

- sync city node names from city display names
- sync route node names from connected city names
- resolve duplicates with numeric suffixes

This is editor convenience only. It helps keep the scene tree readable and predictable.

### `CityNode`

This scene represents a city anchor on the map.

Key exported variables usually include:

- `city_id`  
  Stable identifier used in export.

- `display_name`  
  Human-readable name used for editor display.

- `label_offset`  
  Moves the city label relative to the marker.

- label styling exports  
  Control text color and outline.

- marker styling exports  
  Control marker radius, fill color, outline color, and outline width.

Cities are exported by id and position.

### `RouteNode`

This scene represents a route between two cities.

Key exported variables usually include:

- `from_city`, `to_city`  
  Editor references to the connected cities.

- `route_length`  
  Number of interior route segment points.

- `cart_type`  
  Logical cart color/type exported as a string.

- `label_offset`  
  Moves the route label.

- line styling exports  
  Control line width and endpoint snapping behavior.

- segment styling exports  
  Control the debug rectangle size, outline, and arrow visuals used for previewing route segments.

Routes export:

- source and destination city ids
- cart type
- authored path points
- interior segment points
- per-segment rotation data

## Export format

The JSON export is intended to be consumed by another runtime, such as a Java Swing prototype.

At a high level the export contains:

- `map_id`
- `map_size`
- `normalized`
- `normalization_offset`
- `cities`
- `routes`

Cities contain ids, names, and positions.

Routes contain:

- source city id
- destination city id
- route length
- cart type
- full route points
- interior segment points with rotation

## Editing defaults for all instances

To change defaults globally:

- open `CityNode.tscn` and edit the exported defaults there
- open `RouteNode.tscn` and edit the exported defaults there

This is usually better than changing each placed instance one by one.

## Creating a new map

You do not need to reuse the original map scene.

A normal workflow is:

1. create a new `TicketMapEditor` scene
2. add the required helper/container nodes
3. instance your `CityNode` and `RouteNode` scenes into it
4. author a new level/map there
5. export it to JSON

## AI Declaration

This project was developed with partial assistance from OpenAI's ChatGPT, using the GPT-5.4 Thinking model.

The AI tool was used to support ideation, code generation, refactoring suggestions, implementation planning, and documentation drafting. Final responsibility for selecting, modifying, integrating, and validating the resulting work remained with the project author.

## License

This repository is released under the MIT License.
