classdef SloperApp < matlab.apps.AppBase

    properties (Access = public)
        AppConfigFilename string = "SloperApp.xml"
        UIFigure                   matlab.ui.Figure
        MainGrid                   matlab.ui.container.GridLayout
        TabGroup                   matlab.ui.container.TabGroup

        ImportTab                  matlab.ui.container.Tab
        ImportGrid                 matlab.ui.container.GridLayout
        FileButton                 matlab.ui.control.Button
        FilePathField              matlab.ui.control.EditField
        DatasetNameLabel           matlab.ui.control.Label
        DatasetNameField           matlab.ui.control.EditField
        AddDatasetButton           matlab.ui.control.Button
        DatasetListBox             matlab.ui.control.ListBox
        RemoveDatasetButton        matlab.ui.control.Button
        StatusLabel                matlab.ui.control.Label

        AnalysisTab                matlab.ui.container.Tab
        AnalysisGrid               matlab.ui.container.GridLayout
        ParamPanel                 matlab.ui.container.GridLayout
        DatasetDropdown            matlab.ui.control.DropDown
        NxxField                   matlab.ui.control.Spinner
        NyyField                   matlab.ui.control.Spinner
        NpField                    matlab.ui.control.Spinner
        FIDCheckBox                matlab.ui.control.CheckBox
        OrderField                 matlab.ui.control.Spinner
        SymCheckBox                matlab.ui.control.CheckBox
        RunButton                  matlab.ui.control.Button
        plotStack                  matlab.ui.container.GridLayout
        ContourPlotSag             matlab.graphics.axis.Axes
        ContourPlotLon             matlab.graphics.axis.Axes
        LinePlotGrid               matlab.ui.container.GridLayout
        LinePlotAx1                matlab.graphics.axis.Axes
        LinePlotAx2                matlab.graphics.axis.Axes
        LinePlotAx3                matlab.graphics.axis.Axes
        LinePlotAx4                matlab.graphics.axis.Axes

        ExportTab                  matlab.ui.container.Tab
        ExportGrid                 matlab.ui.container.GridLayout
        ExportDatasetDropdown      matlab.ui.control.DropDown
        ExportDirField             matlab.ui.control.EditField
        BrowseExportDirButton      matlab.ui.control.Button
        DverField                  matlab.ui.control.EditField
        BlnameField                matlab.ui.control.EditField
        OptnameField               matlab.ui.control.EditField
        ScenameField               matlab.ui.control.EditField
        ExportButton               matlab.ui.control.Button
        ExportStatusLabel          matlab.ui.control.Label
    end

    properties (Access = private)
        Datasets         cell = {}
        SelectedIndex    double = 0
        ExportDir        string = ""
    end

    properties (Access = private)
        DefaultNxx    double = 100
        DefaultNyy    double = 20
        DefaultFID    logical = false
        DefaultOrder  double = 3
        DefaultSym    logical = false
        DefaultNp     double = 10
    end

    methods (Access = public)
        function app = SloperApp
            createComponents(app)
            registerApp(app, app.UIFigure)
            startup(app)
            if nargout == 0
                clear app
            end
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('HandleVisibility', 'callback');

            app.MainGrid = uigridlayout(app.UIFigure, [1, 1]);
            app.MainGrid.RowHeight = {'1x'};
            app.MainGrid.ColumnWidth = {'1x'};
            app.MainGrid.Padding = [0, 0, 0, 0];
            app.MainGrid.RowSpacing = 0;
            app.MainGrid.ColumnSpacing = 0;

            app.TabGroup = uitabgroup(app.MainGrid);

            % ============ Tab 1: Import ============
            app.ImportTab = uitab(app.TabGroup, 'Title', 'Import Data');
            app.ImportGrid = uigridlayout(app.ImportTab, [8, 2]);
            app.ImportGrid.RowHeight = {'fit','fit','fit','1x','1x','fit','fit','fit'};
            app.ImportGrid.ColumnWidth = {'fit','1x'};
            app.ImportGrid.Padding = [10, 10, 10, 10];
            app.ImportGrid.RowSpacing = 8;
            app.ImportGrid.ColumnSpacing = 5;

            app.FileButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.FileButtonPushed);
            app.FileButton.Text = 'Browse File...';
            app.FileButton.Tooltip = 'Select ANSYS .txt file';
            app.FileButton.Layout.Row = 1;
            app.FileButton.Layout.Column = 1;

            app.FilePathField = uieditfield(app.ImportGrid);
            app.FilePathField.Editable = false;
            app.FilePathField.Layout.Row = 1;
            app.FilePathField.Layout.Column = 2;

            app.DatasetNameLabel = uilabel(app.ImportGrid);
            app.DatasetNameLabel.Text = 'Dataset Name:';
            app.DatasetNameLabel.Layout.Row = 2;
            app.DatasetNameLabel.Layout.Column = 1;

            app.DatasetNameField = uieditfield(app.ImportGrid);
            app.DatasetNameField.Layout.Row = 2;
            app.DatasetNameField.Layout.Column = 2;

            app.AddDatasetButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.AddDatasetButtonPushed);
            app.AddDatasetButton.Text = 'Add Dataset';
            app.AddDatasetButton.Layout.Row = 3;
            app.AddDatasetButton.Layout.Column = 1;

            app.DatasetListBox = uilistbox(app.ImportGrid);
            app.DatasetListBox.Items = {''};
            app.DatasetListBox.ValueChangedFcn = @app.DatasetListBoxChanged;
            app.DatasetListBox.Layout.Row = [4, 5];
            app.DatasetListBox.Layout.Column = [1, 2];

            app.RemoveDatasetButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.RemoveDatasetButtonPushed);
            app.RemoveDatasetButton.Text = 'Remove Dataset';
            app.RemoveDatasetButton.Layout.Row = 6;
            app.RemoveDatasetButton.Layout.Column = 1;

            app.StatusLabel = uilabel(app.ImportGrid);
            app.StatusLabel.Text = 'Ready';
            app.StatusLabel.Layout.Row = 8;
            app.StatusLabel.Layout.Column = [1, 2];

            % ============ Tab 2: Analysis ============
            app.AnalysisTab = uitab(app.TabGroup, 'Title', 'Analysis');
            app.AnalysisGrid = uigridlayout(app.AnalysisTab, [1, 2]);
            app.AnalysisGrid.ColumnWidth = {220, '1x'};
            app.AnalysisGrid.Padding = [5, 5, 5, 5];
            app.AnalysisGrid.ColumnSpacing = 5;

            % -- Param panel --
            app.ParamPanel = uigridlayout(app.AnalysisGrid, [11, 2]);
            app.ParamPanel.RowHeight = {'fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit'};
            app.ParamPanel.ColumnWidth = {'fit','1x'};
            app.ParamPanel.Padding = [5, 5, 5, 5];
            app.ParamPanel.RowSpacing = 5;
            app.ParamPanel.ColumnSpacing = 5;
            app.ParamPanel.Layout.Row = 1;
            app.ParamPanel.Layout.Column = 1;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Dataset:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 1;
            lbl.Layout.Column = 1;

            app.DatasetDropdown = uidropdown(app.ParamPanel);
            app.DatasetDropdown.Items = {''};
            app.DatasetDropdown.ValueChangedFcn = @app.DatasetDropdownChanged;
            app.DatasetDropdown.Layout.Row = 1;
            app.DatasetDropdown.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Nxx:';
            lbl.Layout.Row = 2;
            lbl.Layout.Column = 1;

            app.NxxField = uispinner(app.ParamPanel);
            app.NxxField.Step = 1;
            app.NxxField.Limits = [1, Inf];
            app.NxxField.ValueChangedFcn = @app.ParamChanged;
            app.NxxField.Layout.Row = 2;
            app.NxxField.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Nyy:';
            lbl.Layout.Row = 3;
            lbl.Layout.Column = 1;

            app.NyyField = uispinner(app.ParamPanel);
            app.NyyField.Step = 1;
            app.NyyField.Limits = [1, Inf];
            app.NyyField.ValueChangedFcn = @app.ParamChanged;
            app.NyyField.Layout.Row = 3;
            app.NyyField.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Np:';
            lbl.Layout.Row = 4;
            lbl.Layout.Column = 1;

            app.NpField = uispinner(app.ParamPanel);
            app.NpField.Step = 1;
            app.NpField.Limits = [1, Inf];
            app.NpField.ValueChangedFcn = @app.ParamChanged;
            app.NpField.Layout.Row = 4;
            app.NpField.Layout.Column = 2;

            lbl = uilabel(app.ParamPanel);
            lbl.Text = 'Order:';
            lbl.Layout.Row = 5;
            lbl.Layout.Column = 1;

            app.OrderField = uispinner(app.ParamPanel);
            app.OrderField.Step = 1;
            app.OrderField.Limits = [1, Inf];
            app.OrderField.Enable = false;
            app.OrderField.ValueChangedFcn = @app.ParamChanged;
            app.OrderField.Layout.Row = 5;
            app.OrderField.Layout.Column = 2;

            app.FIDCheckBox = uicheckbox(app.ParamPanel);
            app.FIDCheckBox.Text = 'FID (Polynomial Fit)';
            app.FIDCheckBox.ValueChangedFcn = @app.FIDChanged;
            app.FIDCheckBox.Layout.Row = 7;
            app.FIDCheckBox.Layout.Column = 1;

            app.SymCheckBox = uicheckbox(app.ParamPanel);
            app.SymCheckBox.Text = 'Sym (Mirror Grid)';
            app.SymCheckBox.ValueChangedFcn = @app.ParamChanged;
            app.SymCheckBox.Layout.Row = 8;
            app.SymCheckBox.Layout.Column = 1;

            app.RunButton = uibutton(app.ParamPanel, 'ButtonPushed', @app.RunButtonPushed);
            app.RunButton.Text = 'Run Analysis';
            app.RunButton.Layout.Row = 10;
            app.RunButton.Layout.Column = 1;

            % -- Plot stack --
            app.plotStack = uigridlayout(app.AnalysisGrid, [3, 1]);
            app.plotStack.RowHeight = {'1x','1x','2x'};
            app.plotStack.Padding = [10, 10, 30, 10];
            app.plotStack.RowSpacing = 3;
            app.plotStack.Layout.Row = 1;
            app.plotStack.Layout.Column = 2;

            app.ContourPlotSag = uiaxes(app.plotStack);
            app.ContourPlotSag.Title.String = 'Sagittal Slope [urad]';
            app.ContourPlotSag.Layout.Row = 1;
            app.ContourPlotSag.Layout.Column = 1;

            app.ContourPlotLon = uiaxes(app.plotStack);
            app.ContourPlotLon.Title.String = 'Longitudinal Slope [urad]';
            app.ContourPlotLon.Layout.Row = 2;
            app.ContourPlotLon.Layout.Column = 1;

            app.LinePlotGrid = uigridlayout(app.plotStack, [2, 2]);
            app.LinePlotGrid.RowHeight = {'1x','1x'};
            app.LinePlotGrid.ColumnWidth = {'1x','1x'};
            app.LinePlotGrid.Padding = [2, 2, 2, 2];
            app.LinePlotGrid.RowSpacing = 2;
            app.LinePlotGrid.ColumnSpacing = 2;
            app.LinePlotGrid.Layout.Row = 3;
            app.LinePlotGrid.Layout.Column = 1;

            app.LinePlotAx1 = axes(app.LinePlotGrid);
            app.LinePlotAx1.Layout.Row = 1;
            app.LinePlotAx1.Layout.Column = 1;

            app.LinePlotAx2 = axes(app.LinePlotGrid);
            app.LinePlotAx2.Layout.Row = 1;
            app.LinePlotAx2.Layout.Column = 2;

            app.LinePlotAx3 = axes(app.LinePlotGrid);
            app.LinePlotAx3.Layout.Row = 2;
            app.LinePlotAx3.Layout.Column = 1;

            app.LinePlotAx4 = axes(app.LinePlotGrid);
            app.LinePlotAx4.Layout.Row = 2;
            app.LinePlotAx4.Layout.Column = 2;

            % ============ Tab 3: Export ============
            app.ExportTab = uitab(app.TabGroup, 'Title', 'Export');
            app.ExportGrid = uigridlayout(app.ExportTab, [10, 2]);
            app.ExportGrid.RowHeight = {'fit','fit','fit','fit','fit','fit','fit','fit','fit','fit'};
            app.ExportGrid.ColumnWidth = {'fit','1x'};
            app.ExportGrid.Padding = [10, 10, 10, 10];
            app.ExportGrid.RowSpacing = 8;
            app.ExportGrid.ColumnSpacing = 5;

            lbl = uilabel(app.ExportGrid);
            lbl.Text = 'Dataset:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 1;
            lbl.Layout.Column = 1;

            app.ExportDatasetDropdown = uidropdown(app.ExportGrid);
            app.ExportDatasetDropdown.Items = {''};
            app.ExportDatasetDropdown.ValueChangedFcn = @app.ExportDatasetDropdownChanged;
            app.ExportDatasetDropdown.Layout.Row = 1;
            app.ExportDatasetDropdown.Layout.Column = 2;

            lbl = uilabel(app.ExportGrid);
            lbl.Text = 'Export Directory:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 2;
            lbl.Layout.Column = 1;

            app.ExportDirField = uieditfield(app.ExportGrid);
            app.ExportDirField.Editable = false;
            app.ExportDirField.Layout.Row = 2;
            app.ExportDirField.Layout.Column = 2;

            app.BrowseExportDirButton = uibutton(app.ExportGrid, 'ButtonPushed', @app.BrowseExportDirButtonPushed);
            app.BrowseExportDirButton.Text = 'Browse...';
            app.BrowseExportDirButton.Layout.Row = 3;
            app.BrowseExportDirButton.Layout.Column = 1;

            lbl = uilabel(app.ExportGrid);
            lbl.Text = 'dver:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 4;
            lbl.Layout.Column = 1;

            app.DverField = uieditfield(app.ExportGrid);
            app.DverField.Value = 'TEST';
            app.DverField.Layout.Row = 4;
            app.DverField.Layout.Column = 2;

            lbl = uilabel(app.ExportGrid);
            lbl.Text = 'blname:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 5;
            lbl.Layout.Column = 1;

            app.BlnameField = uieditfield(app.ExportGrid);
            app.BlnameField.Value = 'X';
            app.BlnameField.Layout.Row = 5;
            app.BlnameField.Layout.Column = 2;

            lbl = uilabel(app.ExportGrid);
            lbl.Text = 'optname:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 6;
            lbl.Layout.Column = 1;

            app.OptnameField = uieditfield(app.ExportGrid);
            app.OptnameField.Value = 'X';
            app.OptnameField.Layout.Row = 6;
            app.OptnameField.Layout.Column = 2;

            lbl = uilabel(app.ExportGrid);
            lbl.Text = 'scename:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 7;
            lbl.Layout.Column = 1;

            app.ScenameField = uieditfield(app.ExportGrid);
            app.ScenameField.Value = 'X';
            app.ScenameField.Layout.Row = 7;
            app.ScenameField.Layout.Column = 2;

            app.ExportButton = uibutton(app.ExportGrid, 'ButtonPushed', @app.ExportButtonPushed);
            app.ExportButton.Text = 'Export';
            app.ExportButton.Layout.Row = 8;
            app.ExportButton.Layout.Column = 1;

            app.ExportStatusLabel = uilabel(app.ExportGrid);
            app.ExportStatusLabel.Text = 'Ready';
            app.ExportStatusLabel.Layout.Row = 10;
            app.ExportStatusLabel.Layout.Column = [1, 2];
        end
    end

    methods (Access = private)
        function startup(app)
            app.NxxField.Value = app.DefaultNxx;
            app.NyyField.Value = app.DefaultNyy;
            app.NpField.Value = app.DefaultNp;
            app.OrderField.Value = app.DefaultOrder;
            app.OrderField.Enable = false;
            app.FIDCheckBox.Value = app.DefaultFID;
            app.SymCheckBox.Value = app.DefaultSym;
            app.DatasetDropdown.Items = {''};
            app.ExportDatasetDropdown.Items = {''};
            app.DatasetListBox.Items = {''};
            app.StatusLabel.Text = 'Ready';
            app.ExportStatusLabel.Text = 'Ready';
        end
    end

    methods (Access = private)

        function refreshDatasetDropdowns(app)
            names = {};
            for i = 1:length(app.Datasets)
                names{end+1} = app.Datasets{i}.name;
            end
            if isempty(names)
                names = {''};
            end
            app.DatasetDropdown.Items = names;
            app.ExportDatasetDropdown.Items = names;
            app.DatasetListBox.Items = names;
            if app.SelectedIndex > 0 && app.SelectedIndex <= length(app.Datasets)
                app.DatasetDropdown.Value = app.Datasets{app.SelectedIndex}.name;
                app.ExportDatasetDropdown.Value = app.Datasets{app.SelectedIndex}.name;
                app.DatasetListBox.Value = app.Datasets{app.SelectedIndex}.name;
            end
        end

        function updateAnalysis(app)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                return
            end

            ds = app.Datasets{app.SelectedIndex};
            try
                [X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w] = ...
                    sloper(ds.filepath, app.NxxField.Value, app.NyyField.Value, ...
                    app.FIDCheckBox.Value, int16(app.OrderField.Value), app.SymCheckBox.Value);

                ds.sloperOutputs = {X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w};
                app.Datasets{app.SelectedIndex} = ds;

                app.plotContour(X, Y, S_sag, S_lon);
                app.plotLines(X, Y, W, S_sag, S_lon);
                app.StatusLabel.Text = 'Analysis updated successfully';
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function plotContour(app, X, Y, S_sag, S_lon)
            cla(app.ContourPlotSag);
            cla(app.ContourPlotLon);

            contourf(app.ContourPlotSag, X, Y, S_sag);
            app.ContourPlotSag.FontSize = 11;
            xlabel(app.ContourPlotSag, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.ContourPlotSag, 'Lon. (y) [mm]', 'FontSize', 11);
            colormap(app.ContourPlotSag, 'bone');
            cb1 = colorbar(app.ContourPlotSag);
            ylabel(cb1, 'Slope [urad]', 'FontSize', 11, 'Rotation', 270);

            contourf(app.ContourPlotLon, X, Y, S_lon);
            app.ContourPlotLon.FontSize = 11;
            xlabel(app.ContourPlotLon, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.ContourPlotLon, 'Lon. (y) [mm]', 'FontSize', 11);
            colormap(app.ContourPlotLon, 'bone');
            cb2 = colorbar(app.ContourPlotLon);
            ylabel(cb2, 'Slope [urad]', 'FontSize', 11, 'Rotation', 270);
        end

        function plotLines(app, X, Y, W, S_sag, S_lon)
            Np = app.NpField.Value;
            if Np < 1
                Np = 1;
            end
            Np = min(Np, min(size(S_lon, 1), size(S_sag, 2)));

            cla(app.LinePlotAx1);
            cla(app.LinePlotAx2);
            cla(app.LinePlotAx3);
            cla(app.LinePlotAx4);

            for i = 1:Np
                idx = i * floor(size(S_lon, 1) / Np);
                idy = i * floor(size(S_sag, 2) / Np);

                plot(app.LinePlotAx1, X(:, idy), W(:, idy));
                hold(app.LinePlotAx1, 'on');

                plot(app.LinePlotAx2, Y(idx, :), W(idx, :));
                hold(app.LinePlotAx2, 'on');

                plot(app.LinePlotAx3, X(:, idy), S_sag(:, idy));
                hold(app.LinePlotAx3, 'on');

                plot(app.LinePlotAx4, Y(idx, :), S_lon(idx, :));
                hold(app.LinePlotAx4, 'on');
            end

            xlabel(app.LinePlotAx1, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx1, 'Normal Disp. [mm]', 'FontSize', 11);
            grid(app.LinePlotAx1, 'on');

            xlabel(app.LinePlotAx2, 'Lon. (y) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx2, 'Normal Disp. [mm]', 'FontSize', 11);
            grid(app.LinePlotAx2, 'on');

            xlabel(app.LinePlotAx3, 'Sag. (x) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx3, 'Sag. (x) Slope [urad]', 'FontSize', 11);
            grid(app.LinePlotAx3, 'on');

            xlabel(app.LinePlotAx4, 'Lon. (y) [mm]', 'FontSize', 11);
            ylabel(app.LinePlotAx4, 'Tan. (y) Slope [urad]', 'FontSize', 11);
            grid(app.LinePlotAx4, 'on');
        end
    end

    methods (Access = private)

        function FileButtonPushed(app, src, event)
            [f, p] = uigetfile('*.txt', 'Select ANSYS Data File');
            if isequal(f, 0)
                return
            end
            app.FilePathField.Value = fullfile(p, f);
        end

        function AddDatasetButtonPushed(app, src, event)
            name = app.DatasetNameField.Value;
            fpath = app.FilePathField.Value;

            if isempty(name)
                app.StatusLabel.Text = 'Please enter a dataset name';
                return
            end
            if isempty(fpath)
                app.StatusLabel.Text = 'Please select a file';
                return
            end
            if ~isfile(fpath)
                app.StatusLabel.Text = 'File does not exist';
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, name)
                    app.StatusLabel.Text = 'Dataset name already exists';
                    return
                end
            end

            try
                [X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w] = ...
                    sloper(fpath, app.DefaultNxx, app.DefaultNyy, ...
                    app.DefaultFID, int16(app.DefaultOrder), app.DefaultSym);

                ds = struct('name', name, 'filepath', fpath, ...
                    'sloperOutputs', {{X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w}});
                app.Datasets{end+1} = ds;
                app.SelectedIndex = length(app.Datasets);
                app.refreshDatasetDropdowns();

                app.DatasetNameField.Value = '';
                app.FilePathField.Value = '';
                app.StatusLabel.Text = ['Dataset "' name '" added successfully'];

                app.updateAnalysis();
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function RemoveDatasetButtonPushed(app, src, event)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                app.StatusLabel.Text = 'No dataset selected';
                return
            end

            removedName = app.Datasets{app.SelectedIndex}.name;
            app.Datasets(app.SelectedIndex) = [];
            if app.SelectedIndex > length(app.Datasets)
                app.SelectedIndex = length(app.Datasets);
            end
            if isempty(app.Datasets)
                app.SelectedIndex = 0;
                cla(app.ContourPlotSag);
                cla(app.ContourPlotLon);
                cla(app.LinePlotAx1);
                cla(app.LinePlotAx2);
                cla(app.LinePlotAx3);
                cla(app.LinePlotAx4);
            end
            app.refreshDatasetDropdowns();
            app.StatusLabel.Text = ['Removed "' removedName '"'];
        end

        function DatasetListBoxChanged(app, src, event)
            val = app.DatasetListBox.Value;
            if isempty(val)
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, val)
                    app.SelectedIndex = i;
                    app.refreshDatasetDropdowns();
                    app.updateAnalysis();
                    break
                end
            end
        end

        function DatasetDropdownChanged(app, src, event)
            val = app.DatasetDropdown.Value;
            if isempty(val)
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, val)
                    app.SelectedIndex = i;
                    app.updateAnalysis();
                    break
                end
            end
        end

        function ParamChanged(app, src, event)
            app.updateAnalysis();
        end

        function FIDChanged(app, src, event)
            app.OrderField.Enable = app.FIDCheckBox.Value;
            app.updateAnalysis();
        end

        function RunButtonPushed(app, src, event)
            app.updateAnalysis();
        end

        function BrowseExportDirButtonPushed(app, src, event)
            d = uigetdir('', 'Select Export Directory');
            if isequal(d, 0)
                return
            end
            app.ExportDir = string(d);
            app.ExportDirField.Value = app.ExportDir;
        end

        function ExportDatasetDropdownChanged(app, src, event)
            val = app.ExportDatasetDropdown.Value;
            if isempty(val)
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, val)
                    app.SelectedIndex = i;
                    break
                end
            end
        end

        function ExportButtonPushed(app, src, event)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                app.ExportStatusLabel.Text = 'No dataset selected';
                return
            end
            if isempty(app.ExportDir)
                app.ExportStatusLabel.Text = 'Please select export directory';
                return
            end

            dver = app.DverField.Value;
            blname = app.BlnameField.Value;
            optname = app.OptnameField.Value;
            scename = app.ScenameField.Value;

            if isempty(dver) || isempty(blname) || isempty(optname) || isempty(scename)
                app.ExportStatusLabel.Text = 'Please fill in all export fields';
                return
            end

            ds = app.Datasets{app.SelectedIndex};
            outputs = ds.sloperOutputs;
            X  = outputs{1};   Y  = outputs{2};   U = outputs{3}; V = outputs{4};
            W  = outputs{5};   S_lon = outputs{6}; S_sag = outputs{7};
            x  = outputs{8};   y  = outputs{9};   u = outputs{10}; v = outputs{11}; w = outputs{12};

            dateStr = string(datetime('now', 'TimeZone', 'local', 'Format', 'dMMMyy'));
            expname = strjoin(["FEA", dver, blname, optname, scename, dateStr], '-');

            try
                sloper_export(app.ExportDir, expname, x, y, X, Y, u, v, w, U, V, W);
                app.ExportStatusLabel.Text = ['Exported: ' expname];
            catch ME
                app.ExportStatusLabel.Text = ['Export error: ' ME.message];
            end
        end
    end

end