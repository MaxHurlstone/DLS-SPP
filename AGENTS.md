# Agent: Implement SloperApp in MATLAB 2026b Plain Text Format

## Task

Create `SloperApp.m` and `SloperApp.xml` — a 3-tab App Designer app using MATLAB 2026b's plain text format. The app wraps `mvp/sloper.m` and `mvp/sloper_export.m` into a multi-dataset GUI with live-updating contour and line plots.

## Source of Truth

Read these files in order:
1. `.kilo/plans/1791202350397-matlab-app-plan.md` — full app spec (tabs, components, logic, risks)
2. `mvp/sloper.m:5-12` — argument types for `sloper()` calls
3. `mvp/sloper.m:29-38` — .txt file column indices (col2=x, col3=y, col5=u, col6=v, col7=w)
4. `mvp/sloper.m:60-67` — `sym` parameter doubles grid row count
5. `mvp/crystal_footprint.m:43-99` — exact plot style to replicate (`contourf`, `colormap bone`, 4-panel line plots, font sizes)
6. `mvp/crystal_footprint.m:19-22` — `expname` construction
7. `mvp/sloper_export.m:1-2` — export argument order (12 args)
8. `SloperApp_src/code/SloperApp.m` — **reference implementation** with all callback logic already written. Steal the callback bodies, property declarations, and plotting helpers directly. This file is the correct implementation — just needs to be split into the 2026b plain text format.

## Output Files

### `SloperApp.m` (MATLAB class — code)

Use MATLAB 2026b plain text App Designer format:
- The class extends `matlab.apps.AppBase`
- Has an `AppConfigFilename` property: `AppConfigFilename string = "SloperApp.xml"`
- All UI component properties are `Access = public` with MATLAB UI types (e.g. `matlab.ui.control.Button`, `matlab.ui.control.Spinner`, `matlab.ui.axes.Axes`)
- State properties (`Datasets`, `SelectedIndex`, `ExportDir`) are `Access = private`
- Default param properties (`DefaultNxx`, `DefaultNyy`, etc.) are `Access = private`
- Callbacks are `Access = private` methods with signature `callbackName(app, event)`
- A `startup(app)` callback method initialises spinner defaults and resets dropdowns

Copy the callback logic verbatim from `SloperApp_src/code/SloperApp.m`:
- `FileButtonPushed`, `AddDatasetButtonPushed`, `RemoveDatasetButtonPushed`
- `DatasetListBoxChanged`, `DatasetDropdownChanged`
- `ParamChanged`, `FIDChanged`, `RunButtonPushed`
- `BrowseExportDirButtonPushed`, `ExportButtonPushed`
- `refreshDatasetDropdowns`, `updateAnalysis`, `plotContour`, `plotLines`

**Component IDs that must match between `.m` and `.xml`:**

| Tab 1 (Import) | Tab 2 (Analysis) | Tab 3 (Export) |
|----------------|-------------------|----------------|
| `FileButton` | `DatasetDropdown` | `ExportDatasetDropdown` |
| `FilePathField` | `NxxField` | `ExportDirField` |
| `DatasetNameField` | `NyyField` | `BrowseExportDirButton` |
| `AddDatasetButton` | `NpField` | `DverField` |
| `DatasetListBox` | `FIDCheckBox` | `BlnameField` |
| `RemoveDatasetButton` | `OrderField` | `OptnameField` |
| `StatusLabel` | `SymCheckBox` | `ScenameField` |
| | `RunButton` | `ExportButton` |
| | `ContourPlotSag` | `ExportStatusLabel` |
| | `ContourPlotLon` | |
| | `LinePlotAx1` .. `LinePlotAx4` | |

### `SloperApp.xml` (App configuration — layout and metadata)

This file defines all components and their layout in App Designer's XML schema. Key format notes:
- Root element: `<UI desc="MainLayout">`
- Inside: `<grid-layout>` tree with component hierarchy
- Each component has `id`, `class` attributes matching the `.m` properties
- Grid position via `<layout row="N" column="N" rowSpan="N" columnSpan="N"/>`
- Callback bindings: `<callback event="EventName" method="CallbackName"/>`
- Event types: `ButtonPushed` (buttons), `ValueChanged` (spinners, dropdowns, checkboxes, listbox)
- Component attributes: `text`, `value`, `editable`, `enabled`, `tooltip`, `buttonStyle`, `items`, `step`, `limits`, `fontWeight`, `title`
- Grid rows/columns use `"1x"` (proportional), `"fit"` (content-sized), or pixel numbers
- Inner containers (like the `ParamPanel`, `plotStack`, `LinePlotGrid`) are nested `<grid-layout>` elements
- Tab structure: `<tab-group>` with `<tabs>` containing `<tab>` elements

**Tab 2 layout specifically:**
```
+----------------+----------------------------+
| ParamPanel     | plotStack                  |
| (11 rows,      | +------------------------+ |
|  2 cols)       | | ContourPlotSag         | |
|                | +------------------------+ |
|                | | ContourPlotLon         | |
|                | +------------------------+ |
|                | | LinePlotGrid (2x2)     | |
|                | | LinePlotAx1..4         | |
|                | +------------------------+ |
+----------------+----------------------------+
```

**Tab 1 layout:** 8 rows x 2 cols in ImportGrid. FileButton + FilePathField row 1. DatasetNameLabel + DatasetNameField row 2. AddDatasetButton row 3 (span both cols). DatasetListBox rows 4-5 (span both cols). RemoveDatasetButton row 6. StatusLabel row 8.

**Tab 3 layout:** 10 rows x 2 cols in ExportGrid. Dataset dropdown row 1. Export dir row 2. Browse button row 3. dver/blname/optname/scename rows 4-7. Export button row 8. StatusLabel row 10.

## Verification

After writing both files, open MATLAB 2026b and run:
```matlab
>> appdesigner('SloperApp.m')
```
This should open the app in App Designer with both Design View and Code View populated. Then test:
1. Run the app: `SloperApp`
2. Import `test_data/test.txt` → name it → plots appear in Analysis tab
3. Change Nxx → plots update
4. Toggle FID → Order spinner enables/disables → plots update
5. Switch datasets in Analysis tab dropdown
6. Export with test metadata → verify files in export dir

## Important Notes

- Do NOT edit `mvp/sloper.m`, `mvp/sloper_export.m`, or any `mvp/` files
- Do NOT create a `.mlapp` file — the plain text format uses `.m` + `.xml`
- Match the exact plot style from `crystal_footprint.m:43-99` (colormap bone, FontSize=11, Rotation=270 on colorbar labels, clipped axes, hold-on line loop)
- Export argument ordering: `sloper_export(expdir, expname, x, y, X, Y, u, v, w, U, V, W)` — the FEA vectors (x,y) come before grid matrices (X,Y)
- `sloper()` requires `int16(order)` for the `order` parameter (its type constraint is `(1,1) int16`)
- Spinners for Nxx/Nyy/Order/Np should have `Limits=[1, Inf]`, `Step=1`
- OrderField should be `Enabled=false` initially, toggled by FIDCheckBox
- `Datasets` is a cell array of structs: `{name, filepath, sloperOutputs}`
- `refreshDatasetDropdowns` syncs Tab 2 and Tab 3 dropdowns + Tab 1 listbox
- `generateSloperApp.m` can be deleted after this is done
- `SloperApp_src/` directory can be deleted after this is done