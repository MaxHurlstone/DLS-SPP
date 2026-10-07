# MATLAB Plain-Text App Guidelines

## File Format

MATLAB 2026b supports a plain-text, two-file format for App Designer apps instead of the binary `.mlapp`:

- **`MyApp.m`** — MATLAB class file (code + property declarations)
- **`MyApp.xml`** — layout and metadata (Design View)

The class extends `matlab.apps.AppBase` and includes:

```
properties (Access = public)
    AppConfigFilename string = "MyApp.xml"
    % ... UI component properties ...
end
```

## Class Structure

### Property Access

| Access   | Contents |
|----------|----------|
| `public` | UI component references (`matlab.ui.control.Button`, `matlab.graphics.axis.Axes`, etc.) |
| `private` | State (`Datasets`, counters), defaults (`DefaultNxx`), helpers |

### UI Component Types

For components created with `uibutton()`, `uispinner()`, etc., declare the properties as:

- `matlab.ui.control.Button`
- `matlab.ui.control.Spinner`
- `matlab.ui.control.DropDown`
- `matlab.ui.control.CheckBox`
- `matlab.ui.control.EditField`
- `matlab.ui.control.ListBox`
- `matlab.ui.control.Label`
- `matlab.graphics.axis.Axes` (returned by `uiaxes()`)
- `matlab.ui.control.Tab`
- `matlab.ui.container.GridLayout`

## Pattern for Component IDs

Every UI element needs two declarations:
1. A **property** in the `.m` file (matches the `id` in `.xml`)
2. A **grid-layout entry** in the `.xml` file with matching `id`

## Callbacks

Methods are `Access = private` with 3 parameters:

```
function myCallback(app, src, event)
    % src — the UI component that fired the event
    % event — event object (may carry old/new values, etc.)
end
```

Bind in `.xml` via `<callback>`:

```
<callback event="ButtonPushed" method="myCallback"/>
```

### Common Event Types

| Component | Event Name | Trigger |
|-----------|-----------|---------|
| Button | `ButtonPushed` | Click |
| Spinner | `ValueChanged` | Value change |
| DropDown | `ValueChanged` | Selection change |
| CheckBox | `ValueChanged` | Toggle |
| EditField | `ValueChanged` | Confirm edit |
| ListBox | `ValueChanged` | Selection change |

## Grid Layout

Each component gets a layout position in `createComponents()`:

```
comp.Layout.Row = rowNumber;
comp.Layout.Column = columnNumber;
```

For spanning multiple rows or columns:

```
comp.Layout.Row = [startRow, endRow];       % rowSpan
comp.Layout.Column = [startCol, endCol];    % columnSpan
```

There are **no separate `RowSpan`/`ColumnSpan` properties** in MATLAB 2026b plain text — use vector notation on `Row`/`Column`.

### Grid Column Widths

In `uigridlayout`, set:

- `'fit'` — sized to content (labels, buttons)
- `'1x'`, `'2x'` — proportional stretch (fields, plots)
- Pixel values (e.g., `120`) — fixed width

Example: `grid.ColumnWidth = {'fit', '1x'};` gives a label column + a stretchable field column.

### Padding

Containers (grid layouts, tab panels) accept a `Padding` array: `[top, right, bottom, left]`. Use this instead of margins on individual components. Increase right padding (e.g., `[10, 30, 10, 10]`) when colorbar labels or other UI extends past the plot edge.

## XML Layout Schema

```
<UI desc="MainLayout">
  <grid-layout>   <!-- the root grid/figure -->
    <grid-layout row="1" column="1">   <!-- tab group row -->
      <tab-group>
        <tabs>
          <tab id="ImportTab" title="Import">
            <grid-layout columns="2">
              <!-- components here -->
            </grid-layout>
          </tab>
        </tabs>
      </tab-group>
    </grid-layout>
  </grid-layout>
</UI>
```

### Component Entry

```
<component id="FileButton" class="Button">
  <layout row="1" column="1"/>
  <button text="Browse..."/>
  <callback event="ButtonPushed" method="FileButtonPushed"/>
</component>
```

Grid positions map directly (1-indexed). The `layout` element can include `rowSpan` and `columnSpan` attributes.

## Known Pitfalls (MATLAB 2026b)

| What doesn't work | What to use instead |
|-------------------|---------------------|
| `Enabled` property on Spinner | `Enable` |
| `ButtonStyle` on Button | Not available — omit |
| `Title` on `uifigure` | Not available — omit |
| `matlab.ui.control.UIAxes` for axes properties | `matlab.graphics.axis.Axes` (`uiaxes()` returns this type) |
| Assigning `.Value` before `.Items` on a DropDown/ListBox | Set `.Items` first, then `.Value` |

## Object Cleanup

Override `delete` to close figures gracefully:

```
methods (Access = public)
    function delete(app)
        if ishandle(app.myFigure)
            close(app.myFigure);
        end
    end
end
```

## Startup Pattern

Create a `startup(app)` callback bound to the figure's `Startup` event (or call it from the constructor). Use it for:

1. Setting spinner limits and defaults
2. Populating dropdowns
3. Resetting state

## Plot Styling Reference

When replicating specific plot styles (fonts, colormaps, colorbars), match the target exactly:

```matlab
contourf(X, Y, Z, 20);
colormap(gca, 'bone');
c = colorbar();
c.Label.Rotation = 270;
ax.FontSize = 11;
```

## Testing

- Open Design View: `appdesigner('MyApp.m')`
- Run: `MyApp`
- Check: component IDs match, callbacks fire, layout resizes correctly