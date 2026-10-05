classdef SloperApp < matlab.apps.AppBase

    properties (Access = public)
        AppConfigFilename string = "SloperApp.xml"
    end

    properties (Access = public)
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
        ContourPlotSag             matlab.ui.axes.Axes
        ContourPlotLon             matlab.ui.axes.Axes
        LinePlotGrid               matlab.ui.container.GridLayout
        LinePlotAx1                matlab.ui.axes.Axes
        LinePlotAx2                matlab.ui.axes.Axes
        LinePlotAx3                matlab.ui.axes.Axes
        LinePlotAx4                matlab.ui.axes.Axes

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

    methods (Access = private)
        function startup(app)
            app.NxxField.Value = app.DefaultNxx;
            app.NyyField.Value = app.DefaultNyy;
            app.NpField.Value = app.DefaultNp;
            app.OrderField.Value = app.DefaultOrder;
            app.OrderField.Enabled = false;
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

        function FileButtonPushed(app, event)
            [f, p] = uigetfile('*.txt', 'Select ANSYS Data File');
            if isequal(f, 0)
                return
            end
            app.FilePathField.Value = fullfile(p, f);
        end

        function AddDatasetButtonPushed(app, event)
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

        function RemoveDatasetButtonPushed(app, event)
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

        function DatasetListBoxChanged(app, event)
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

        function DatasetDropdownChanged(app, event)
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

        function ParamChanged(app, event)
            app.updateAnalysis();
        end

        function FIDChanged(app, event)
            app.OrderField.Enabled = app.FIDCheckBox.Value;
            app.updateAnalysis();
        end

        function RunButtonPushed(app, event)
            app.updateAnalysis();
        end

        function BrowseExportDirButtonPushed(app, event)
            d = uigetdir('', 'Select Export Directory');
            if isequal(d, 0)
                return
            end
            app.ExportDir = string(d);
            app.ExportDirField.Value = app.ExportDir;
        end

        function ExportButtonPushed(app, event)
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