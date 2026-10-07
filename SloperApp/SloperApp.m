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
        DataTypeDropdown           matlab.ui.control.DropDown
        DirectionDropdown          matlab.ui.control.DropDown
        AddDatasetButton           matlab.ui.control.Button
        DatasetListBox             matlab.ui.control.ListBox
        RemoveDatasetButton        matlab.ui.control.Button
        ExportDirField             matlab.ui.control.EditField
        BrowseExportDirButton      matlab.ui.control.Button
        DverField                  matlab.ui.control.EditField
        BlnameField                matlab.ui.control.EditField
        OptnameField               matlab.ui.control.EditField
        ScenameField               matlab.ui.control.EditField
        ExportStatusLabel          matlab.ui.control.Label
        ImportExportButton         matlab.ui.control.Button

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
        ExportDataButton           matlab.ui.control.Button
        plotStack                  matlab.ui.container.GridLayout
        TopPlotGroup               matlab.ui.container.GridLayout
        ContourPlotSag             matlab.graphics.axis.Axes
        ContourPlotLon             matlab.graphics.axis.Axes
        BottomPlotGroup            matlab.ui.container.GridLayout
        LinePlotAx1                matlab.graphics.axis.Axes
        LinePlotAx2                matlab.graphics.axis.Axes
        LinePlotAx3                matlab.graphics.axis.Axes
        LinePlotAx4                matlab.graphics.axis.Axes
        AnalysisStatusLabel        matlab.ui.control.Label
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

            % ============ Tab 1: Import Data (with Export fields) ============
            app.ImportTab = uitab(app.TabGroup, 'Title', 'Import Data');
            app.ImportGrid = uigridlayout(app.ImportTab, [15, 2]);
            app.ImportGrid.RowHeight = {'fit','fit','fit','fit',80,80,'fit','fit','fit','fit','fit','fit','fit','fit','fit'};
            app.ImportGrid.ColumnWidth = {'fit', 250};
            app.ImportGrid.Padding = [10, 10, 10, 10];
            app.ImportGrid.RowSpacing = 5;
            app.ImportGrid.ColumnSpacing = 5;

            app.FileButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.FileButtonPushed);
            app.FileButton.Text = 'Browse File...';
            app.FileButton.Tooltip = 'Select ANSYS .txt file';
            app.FileButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.FileButton.FontColor = [0.996, 0.835, 0.008];
            app.FileButton.Layout.Row = 1;
            app.FileButton.Layout.Column = 1;

            app.FilePathField = uieditfield(app.ImportGrid);
            app.FilePathField.Editable = false;
            app.FilePathField.Layout.Row = 1;
            app.FilePathField.Layout.Column = 2;

            app.DatasetNameLabel = uilabel(app.ImportGrid);
            app.DatasetNameLabel.Text = 'Dataset Name:';
            app.DatasetNameLabel.FontWeight = 'bold';
            app.DatasetNameLabel.Layout.Row = 2;
            app.DatasetNameLabel.Layout.Column = 1;

            app.DatasetNameField = uieditfield(app.ImportGrid);
            app.DatasetNameField.Layout.Row = 2;
            app.DatasetNameField.Layout.Column = 2;

            app.DataTypeDropdown = uidropdown(app.ImportGrid);
            app.DataTypeDropdown.Items = {'2D', '1D'};
            app.DataTypeDropdown.Value = '2D';
            app.DataTypeDropdown.Tooltip = 'Select data type (2D surface or 1D profile)';
            app.DataTypeDropdown.ValueChangedFcn = @app.DataTypeDropdownChanged;
            app.DataTypeDropdown.Layout.Row = 3;
            app.DataTypeDropdown.Layout.Column = 1;

            app.DirectionDropdown = uidropdown(app.ImportGrid);
            app.DirectionDropdown.Items = {'Sagittal', 'Longitudinal'};
            app.DirectionDropdown.Value = 'Sagittal';
            app.DirectionDropdown.Enable = false;
            app.DirectionDropdown.Tooltip = 'Select profile direction for 1D data';
            app.DirectionDropdown.Layout.Row = 3;
            app.DirectionDropdown.Layout.Column = 2;

            app.AddDatasetButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.AddDatasetButtonPushed);
            app.AddDatasetButton.Text = 'Add Dataset';
            app.AddDatasetButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.AddDatasetButton.FontColor = [0.996, 0.835, 0.008];
            app.AddDatasetButton.FontWeight = 'bold';
            app.AddDatasetButton.Layout.Row = 4;
            app.AddDatasetButton.Layout.Column = [1, 2];

            app.DatasetListBox = uilistbox(app.ImportGrid);
            app.DatasetListBox.Items = {''};
            app.DatasetListBox.ValueChangedFcn = @app.DatasetListBoxChanged;
            app.DatasetListBox.Layout.Row = [5, 6];
            app.DatasetListBox.Layout.Column = [1, 2];

            app.RemoveDatasetButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.RemoveDatasetButtonPushed);
            app.RemoveDatasetButton.Text = 'Remove Dataset';
            app.RemoveDatasetButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.RemoveDatasetButton.FontColor = [0.996, 0.835, 0.008];
            app.RemoveDatasetButton.FontWeight = 'bold';
            app.RemoveDatasetButton.Layout.Row = 7;
            app.RemoveDatasetButton.Layout.Column = [1, 2];

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'Export Directory:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 8;
            lbl.Layout.Column = 1;

            app.ExportDirField = uieditfield(app.ImportGrid);
            app.ExportDirField.Editable = false;
            app.ExportDirField.Layout.Row = 8;
            app.ExportDirField.Layout.Column = 2;

            app.BrowseExportDirButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.BrowseExportDirButtonPushed);
            app.BrowseExportDirButton.Text = 'Browse...';
            app.BrowseExportDirButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.BrowseExportDirButton.FontColor = [0.996, 0.835, 0.008];
            app.BrowseExportDirButton.Layout.Row = 9;
            app.BrowseExportDirButton.Layout.Column = [1, 2];

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'dver:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 10;
            lbl.Layout.Column = 1;

            app.DverField = uieditfield(app.ImportGrid);
            app.DverField.Value = 'TEST';
            app.DverField.Layout.Row = 10;
            app.DverField.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'blname:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 11;
            lbl.Layout.Column = 1;

            app.BlnameField = uieditfield(app.ImportGrid);
            app.BlnameField.Value = 'X';
            app.BlnameField.Layout.Row = 11;
            app.BlnameField.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'optname:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 12;
            lbl.Layout.Column = 1;

            app.OptnameField = uieditfield(app.ImportGrid);
            app.OptnameField.Value = 'X';
            app.OptnameField.Layout.Row = 12;
            app.OptnameField.Layout.Column = 2;

            lbl = uilabel(app.ImportGrid);
            lbl.Text = 'scename:';
            lbl.FontWeight = 'bold';
            lbl.Layout.Row = 13;
            lbl.Layout.Column = 1;

            app.ScenameField = uieditfield(app.ImportGrid);
            app.ScenameField.Value = 'X';
            app.ScenameField.Layout.Row = 13;
            app.ScenameField.Layout.Column = 2;

            app.ImportExportButton = uibutton(app.ImportGrid, 'ButtonPushed', @app.ExportButtonPushed);
            app.ImportExportButton.Text = 'Export Data';
            app.ImportExportButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.ImportExportButton.FontColor = [0.996, 0.835, 0.008];
            app.ImportExportButton.FontWeight = 'bold';
            app.ImportExportButton.Layout.Row = 14;
            app.ImportExportButton.Layout.Column = [1, 2];

            app.ExportStatusLabel = uilabel(app.ImportGrid);
            app.ExportStatusLabel.Text = 'Ready';
            app.ExportStatusLabel.FontWeight = 'bold';
            app.ExportStatusLabel.FontColor = [0.5, 0.5, 0.5];
            app.ExportStatusLabel.Layout.Row = 15;
            app.ExportStatusLabel.Layout.Column = [1, 2];

            % ============ Tab 2: Analysis ============
            app.AnalysisTab = uitab(app.TabGroup, 'Title', 'Analysis');
            app.AnalysisGrid = uigridlayout(app.AnalysisTab, [1, 2]);
            app.AnalysisGrid.ColumnWidth = {220, '1x'};
            app.AnalysisGrid.Padding = [5, 5, 5, 5];
            app.AnalysisGrid.ColumnSpacing = 5;

            % -- Param panel --
            app.ParamPanel = uigridlayout(app.AnalysisGrid, [12, 2]);
            app.ParamPanel.RowHeight = {'fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit'};
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
            lbl.FontWeight = 'bold';
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
            lbl.FontWeight = 'bold';
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
            lbl.FontWeight = 'bold';
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
            lbl.FontWeight = 'bold';
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
            app.RunButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.RunButton.FontColor = [0.996, 0.835, 0.008];
            app.RunButton.FontWeight = 'bold';
            app.RunButton.Layout.Row = 10;
            app.RunButton.Layout.Column = 1;

            app.ExportDataButton = uibutton(app.ParamPanel, 'ButtonPushed', @app.ExportButtonPushed);
            app.ExportDataButton.Text = 'Export Data';
            app.ExportDataButton.BackgroundColor = [0.125, 0.161, 0.275];
            app.ExportDataButton.FontColor = [0.996, 0.835, 0.008];
            app.ExportDataButton.FontWeight = 'bold';
            app.ExportDataButton.Layout.Row = 11;
            app.ExportDataButton.Layout.Column = 1;

            app.AnalysisStatusLabel = uilabel(app.ParamPanel);
            app.AnalysisStatusLabel.Text = 'Ready';
            app.AnalysisStatusLabel.FontWeight = 'bold';
            app.AnalysisStatusLabel.FontColor = [0.5, 0.5, 0.5];
            app.AnalysisStatusLabel.Layout.Row = 12;
            app.AnalysisStatusLabel.Layout.Column = [1, 2];

            % -- Plot stack (2 rows: top = contours, bottom = line plots) --
            app.plotStack = uigridlayout(app.AnalysisGrid, [2, 1]);
            app.plotStack.RowHeight = {'1x','1x'};
            app.plotStack.Padding = [10, 10, 30, 10];
            app.plotStack.RowSpacing = 3;
            app.plotStack.Layout.Row = 1;
            app.plotStack.Layout.Column = 2;

            % Top plot group: contour axes in 2x1 grid
            app.TopPlotGroup = uigridlayout(app.plotStack, [2, 1]);
            app.TopPlotGroup.RowHeight = {'1x','1x'};
            app.TopPlotGroup.ColumnWidth = {'1x'};
            app.TopPlotGroup.Padding = [2, 2, 2, 2];
            app.TopPlotGroup.RowSpacing = 2;
            app.TopPlotGroup.ColumnSpacing = 2;
            app.TopPlotGroup.Layout.Row = 1;
            app.TopPlotGroup.Layout.Column = 1;

            app.ContourPlotSag = uiaxes(app.TopPlotGroup);
            app.ContourPlotSag.Title.String = 'Sagittal Slope [urad]';
            app.ContourPlotSag.Layout.Row = 1;
            app.ContourPlotSag.Layout.Column = 1;

            app.ContourPlotLon = uiaxes(app.TopPlotGroup);
            app.ContourPlotLon.Title.String = 'Longitudinal Slope [urad]';
            app.ContourPlotLon.Layout.Row = 2;
            app.ContourPlotLon.Layout.Column = 1;

            % Bottom plot group: line axes in 2x2 grid
            app.BottomPlotGroup = uigridlayout(app.plotStack, [2, 2]);
            app.BottomPlotGroup.RowHeight = {'1x','1x'};
            app.BottomPlotGroup.ColumnWidth = {'1x','1x'};
            app.BottomPlotGroup.Padding = [2, 2, 2, 2];
            app.BottomPlotGroup.RowSpacing = 2;
            app.BottomPlotGroup.ColumnSpacing = 2;
            app.BottomPlotGroup.Layout.Row = 2;
            app.BottomPlotGroup.Layout.Column = 1;

            app.LinePlotAx1 = axes(app.BottomPlotGroup);
            app.LinePlotAx1.Layout.Row = 1;
            app.LinePlotAx1.Layout.Column = 1;

            app.LinePlotAx2 = axes(app.BottomPlotGroup);
            app.LinePlotAx2.Layout.Row = 1;
            app.LinePlotAx2.Layout.Column = 2;

            app.LinePlotAx3 = axes(app.BottomPlotGroup);
            app.LinePlotAx3.Layout.Row = 2;
            app.LinePlotAx3.Layout.Column = 1;

            app.LinePlotAx4 = axes(app.BottomPlotGroup);
            app.LinePlotAx4.Layout.Row = 2;
            app.LinePlotAx4.Layout.Column = 2;
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
            app.DataTypeDropdown.Value = '2D';
            app.DirectionDropdown.Value = 'Sagittal';
            app.DirectionDropdown.Enable = false;
            app.DatasetDropdown.Items = {''};
            app.DatasetListBox.Items = {''};
            app.ExportStatusLabel.Text = 'Ready';
            app.AnalysisStatusLabel.Text = 'Ready';
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
            app.DatasetListBox.Items = names;
            if app.SelectedIndex > 0 && app.SelectedIndex <= length(app.Datasets)
                app.DatasetDropdown.Value = app.Datasets{app.SelectedIndex}.name;
                app.DatasetListBox.Value = app.Datasets{app.SelectedIndex}.name;
            end
        end

        function updateAnalysis(app)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                return
            end

            ds = app.Datasets{app.SelectedIndex};
            try
                data0 = ds.data0;
                if ~ds.is2D && strcmp(ds.direction, 'Longitudinal')
                    data0 = data0(:, [1, 3, 2, 4, 5, 6, 7]);
                end

                [X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w] = ...
                    sloper(data0, app.NxxField.Value, app.NyyField.Value, ...
                    app.FIDCheckBox.Value, int16(app.OrderField.Value), ...
                    app.SymCheckBox.Value, ds.is2D);

                ds.sloperOutputs = {X, Y, U, V, W, S_lon, S_sag, x, y, u, v, w};
                app.Datasets{app.SelectedIndex} = ds;

                app.updatePlots(ds, X, Y, W, S_sag, S_lon);
                app.AnalysisStatusLabel.Text = 'Analysis updated successfully';
                app.AnalysisStatusLabel.FontColor = [0, 0.5, 0];
            catch ME
                app.AnalysisStatusLabel.Text = ['Analysis error: ' ME.message];
                app.AnalysisStatusLabel.FontColor = [0.8, 0, 0];
            end
        end

        function updatePlots(app, ds, X, Y, W, S_sag, S_lon)
            if ds.is2D
                app.plotContour2D(X, Y, S_sag, S_lon);
                app.plotLines2D(X, Y, W, S_sag, S_lon);

                app.ContourPlotSag.Layout.Row = 1;
                app.ContourPlotSag.Layout.Column = 1;
                app.ContourPlotLon.Layout.Row = 2;
                app.ContourPlotLon.Layout.Column = 1;
                app.ContourPlotLon.Visible = 'on';

                app.LinePlotAx1.Layout.Row = 1;
                app.LinePlotAx1.Layout.Column = 1;
                app.LinePlotAx2.Layout.Row = 1;
                app.LinePlotAx2.Layout.Column = 2;
                app.LinePlotAx3.Layout.Row = 2;
                app.LinePlotAx3.Layout.Column = 1;
                app.LinePlotAx4.Layout.Row = 2;
                app.LinePlotAx4.Layout.Column = 2;
                app.LinePlotAx2.Visible = 'on';
                app.LinePlotAx3.Visible = 'on';
                app.LinePlotAx4.Visible = 'on';
            else
                app.plot1D(ds, X, Y, W, S_sag, S_lon);

                cla(app.ContourPlotLon);
                app.ContourPlotLon.Visible = 'off';
                app.ContourPlotSag.Layout.Row = [1, 2];
                app.ContourPlotSag.Layout.Column = 1;

                cla(app.LinePlotAx2);
                app.LinePlotAx2.Visible = 'off';
                cla(app.LinePlotAx3);
                app.LinePlotAx3.Visible = 'off';
                cla(app.LinePlotAx4);
                app.LinePlotAx4.Visible = 'off';
                app.LinePlotAx1.Layout.Row = [1, 2];
                app.LinePlotAx1.Layout.Column = [1, 2];
            end
        end

        function plotContour2D(app, X, Y, S_sag, S_lon)
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

        function plotLines2D(app, X, Y, W, S_sag, S_lon)
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

        function plot1D(app, ds, X, Y, W, S_sag, S_lon)
            cla(app.ContourPlotSag);
            cla(app.LinePlotAx1);
            colorbar(app.ContourPlotSag, 'off');
            colorbar(app.LinePlotAx1, 'off');

            if strcmp(ds.direction, 'Sagittal')
                posLabel = 'Sag. (x) [mm]';
                deformTitle = 'Sagittal Deformation';
                slopeTitle = 'Sagittal Slope [urad]';
            else
                posLabel = 'Lon. (y) [mm]';
                deformTitle = 'Longitudinal Deformation';
                slopeTitle = 'Longitudinal Slope [urad]';
            end

            pos = X(:,1);

            plot(app.ContourPlotSag, pos, W(:,1), 'k-', 'LineWidth', 1.5);
            xlabel(app.ContourPlotSag, posLabel, 'FontSize', 11);
            ylabel(app.ContourPlotSag, 'Normal Disp. [mm]', 'FontSize', 11);
            title(app.ContourPlotSag, deformTitle, 'FontSize', 11);
            grid(app.ContourPlotSag, 'on');

            plot(app.LinePlotAx1, pos, S_sag(:,1), 'k-', 'LineWidth', 1.5);
            xlabel(app.LinePlotAx1, posLabel, 'FontSize', 11);
            ylabel(app.LinePlotAx1, 'Slope [urad]', 'FontSize', 11);
            title(app.LinePlotAx1, slopeTitle, 'FontSize', 11);
            grid(app.LinePlotAx1, 'on');
        end

        function exportAxesGrid(app, axesList, nRows, nCols, fn)
            f = figure('Visible', 'off', 'Color', 'w');
            for i = 1:numel(axesList)
                src = axesList{i};
                ax = subplot(nRows, nCols, i);
                copyobj(allchild(src), ax);
                ax.FontSize = src.FontSize;
                ax.XLabel.String = src.XLabel.String;
                ax.YLabel.String = src.YLabel.String;
                ax.Title.String = src.Title.String;
                ax.XLim = src.XLim;
                ax.YLim = src.YLim;
                ax.XGrid = src.XGrid;
                ax.YGrid = src.YGrid;
                ax.Box = src.Box;
                cmap = src.Colormap;
                if ~isempty(cmap)
                    colormap(ax, cmap);
                end
                cb_src = findobj(src, 'Type', 'Colorbar');
                if ~isempty(cb_src)
                    cb = colorbar(ax);
                    cb.Label.String = cb_src.Label.String;
                    cb.Label.FontSize = cb_src.Label.FontSize;
                    cb.Label.Rotation = cb_src.Label.Rotation;
                end
            end
            exportgraphics(f, fn, 'Resolution', 150);
            delete(f);
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

        function DataTypeDropdownChanged(app, src, event)
            is1D = strcmp(app.DataTypeDropdown.Value, '1D');
            app.DirectionDropdown.Enable = is1D;
        end

        function AddDatasetButtonPushed(app, src, event)
            name = app.DatasetNameField.Value;
            fpath = app.FilePathField.Value;

            if isempty(name)
                app.ExportStatusLabel.Text = 'Please enter a dataset name';
                return
            end
            if isempty(fpath)
                app.ExportStatusLabel.Text = 'Please select a file';
                return
            end
            if ~isfile(fpath)
                app.ExportStatusLabel.Text = 'File does not exist';
                return
            end
            for i = 1:length(app.Datasets)
                if strcmp(app.Datasets{i}.name, name)
                    app.ExportStatusLabel.Text = 'Dataset name already exists';
                    return
                end
            end

            try
                data0 = readmatrix(fpath, 'FileType', 'text', 'Delimiter', '\t', 'NumHeaderLines', 1);
                data0 = unique(data0, 'rows');

                is2D = strcmp(app.DataTypeDropdown.Value, '2D');
                direction = app.DirectionDropdown.Value;

                ds = struct('name', name, 'filepath', fpath, 'data0', data0, ...
                    'is2D', is2D, 'direction', direction, 'sloperOutputs', {{}});
                app.Datasets{end+1} = ds;
                app.SelectedIndex = length(app.Datasets);
                app.refreshDatasetDropdowns();

                app.DatasetNameField.Value = '';
                app.FilePathField.Value = '';
                app.ExportStatusLabel.Text = ['Dataset "' name '" added successfully'];
            catch ME
                app.ExportStatusLabel.Text = ['Import error: ' ME.message];
            end
        end

        function RemoveDatasetButtonPushed(app, src, event)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                app.ExportStatusLabel.Text = 'No dataset selected';
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
            app.ExportStatusLabel.Text = ['Removed "' removedName '"'];
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
                    ds = app.Datasets{app.SelectedIndex};
                    app.SymCheckBox.Enable = ds.is2D;
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

        function ExportButtonPushed(app, src, event)
            if app.SelectedIndex < 1 || app.SelectedIndex > length(app.Datasets)
                app.ExportStatusLabel.Text = 'No dataset selected';
                return
            end
            expdir = app.ExportDirField.Value;
            if isempty(expdir)
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
            if isempty(outputs) || numel(outputs) < 12
                app.ExportStatusLabel.Text = 'Run analysis before exporting';
                return
            end
            X  = outputs{1};   Y  = outputs{2};   U = outputs{3}; V = outputs{4};
            W  = outputs{5};   S_lon = outputs{6}; S_sag = outputs{7};
            x  = outputs{8};   y  = outputs{9};   u = outputs{10}; v = outputs{11}; w = outputs{12};

            dateStr = string(datetime('now', 'TimeZone', 'local', 'Format', 'dMMMyy'));
            if ds.is2D
                dimLabel = '2D';
            elseif strcmp(ds.direction, 'Sagittal')
                dimLabel = '1D-sag';
            else
                dimLabel = '1D-lon';
            end
            expname = strjoin(["FEA", dver, blname, optname, scename, dimLabel, dateStr], '-');

            prefix = strjoin(["FEA", dver, blname, optname, scename], '-');
            oldFiles = dir(fullfile(expdir, prefix + '-*'));
            for k = 1:length(oldFiles)
                if ~oldFiles(k).isdir
                    delete(fullfile(oldFiles(k).folder, oldFiles(k).name));
                end
            end

            try
                sloper_export(expdir, expname, x, y, X, Y, u, v, w, U, V, W);

                drawnow;
                pause(0.05);
                fn = fullfile(expdir, expname);
                if ds.is2D
                    app.exportAxesGrid({app.ContourPlotSag, app.ContourPlotLon}, 2, 1, fn + '-ContourPlots.png');
                    app.exportAxesGrid({app.LinePlotAx1, app.LinePlotAx2, app.LinePlotAx3, app.LinePlotAx4}, 2, 2, fn + '-LinePlots.png');
                else
                    exportgraphics(app.ContourPlotSag, fn + '-Deformation.png', 'Resolution', 150);
                    exportgraphics(app.LinePlotAx1, fn + '-Slope.png', 'Resolution', 150);
                end

                app.AnalysisStatusLabel.Text = ['Exported: ' expname];
                app.AnalysisStatusLabel.FontColor = [0, 0.5, 0];
            catch ME
                app.AnalysisStatusLabel.Text = ['Export error: ' ME.message];
                app.AnalysisStatusLabel.FontColor = [0.8, 0, 0];
            end
        end
    end

end