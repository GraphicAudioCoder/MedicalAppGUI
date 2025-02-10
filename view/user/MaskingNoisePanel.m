% /view/user/MaskingNoisePanel.m

classdef MaskingNoisePanel < handle
    properties
        mainWindow
        components
        controller
        scrollableArea % Aggiungi questa proprietà
    end
    
    methods
        function obj = MaskingNoisePanel(mainWindow, controller)
            NamesFonts;
            theme = ThemeManager();

            obj.mainWindow = mainWindow;
            obj.components = containers.Map();
            obj.controller = controller;
           
            selectMaskingNoiseLabel = uilabel(obj.mainWindow, ...
                'Text', 'Select masking noise specs: ', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', ...
                'Position', [475, 600, 400, 30]);
            obj.components('selectMaskingNoiseLabel') = selectMaskingNoiseLabel;  

            % Checkbox for "No masking noise"
            noMaskingNoiseCheckBox = uicheckbox(obj.mainWindow, ...
                'Text', 'No masking noise', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'Position', [USER_PANEL_X_START + 50, 550, 200, 30], ...
                'Tooltip', 'Disable all masking noise', ...
                'ValueChangedFcn', @(src, event) obj.onNoMaskingNoiseCheckBoxChanged());
            obj.components('noMaskingNoiseCheckBox') = noMaskingNoiseCheckBox;

            % Checkbox for "Located noise"
            locatedNoiseCheckBox = uicheckbox(obj.mainWindow, ...
                'Text', 'Located noise', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'Position', [USER_PANEL_X_START + 50, 510, 200, 30], ...
                'Tooltip', 'Enable located noise', ...
                'Value', true, ... % Set default value to true
                'ValueChangedFcn', @(src, event) obj.onLocatedNoiseCheckBoxChanged());
            obj.components('locatedNoiseCheckBox') = locatedNoiseCheckBox;

            % Checkbox for "Diffused Noise (background)"
            diffusedNoiseCheckBox = uicheckbox(obj.mainWindow, ...
                'Text', 'Diffused Noise (background)', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'Position', [USER_PANEL_X_START + 400, 550, 350, 30], ...
                'Tooltip', 'Enable diffused background noise', ...
                'ValueChangedFcn', @(src, event) obj.onDiffusedNoiseCheckBoxChanged());
            obj.components('diffusedNoiseCheckBox') = diffusedNoiseCheckBox;

            % Label for "N°"
            numberLabel = uilabel(obj.mainWindow, ...
                'Text', 'N°', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'Position', [USER_PANEL_X_START + 400, 510, 20, 30], ...
                'Tooltip', 'Number of located noise sources');
            obj.components('numberLabel') = numberLabel;

            % NumberBox for the number
            numberBox = uieditfield(obj.mainWindow, 'numeric', ...
                'Value', 1, ...
                'Editable', 'off', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'BackgroundColor', theme.USER_GUI_ELEM_COLOR_ONE, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'Position', [USER_PANEL_X_START + 430, 510, 50, 30], ...
                'Tooltip', 'Number of located noise sources');
            obj.components('numberBox') = numberBox;

            % Main Scrollable Panel
            obj.components('mainPanel') = uipanel('Parent', mainWindow, ...
                'Position', [USER_PANEL_X_START, 100, 1060 - USER_PANEL_X_START, 380], ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                'Units', 'pixels'); 

            % Scrollable Area inside the mainPanel
            obj.scrollableArea = uigridlayout(obj.components('mainPanel'), ...
                'Scrollable', 'on', ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                'RowHeight', repmat({400}, 1, 10), ... % Height of 400 pixels for 10 rows
                'ColumnWidth', {'1x'}); % One expandable column
        end
        
        % Sets the visibility of all components
        function setVisibility(obj, visibility)
            keys = obj.components.keys;
            for i = 1:length(keys)
                componentName = keys{i};
                if isvalid(obj.components(componentName))
                    component = obj.components(componentName);
                    if visibility
                        component.Visible = 'on';
                    else
                        component.Visible = 'off';
                    end
                end
            end
        end
        
         % Shows a component
         function showComponent(obj, componentName)
            if isKey(obj.components, componentName)
                component = obj.components(componentName);
                component.Visible = 'on';
            end
        end

        % Hide a component
        function hideComponent(obj, componentName)
            if isKey(obj.components, componentName)
                component = obj.components(componentName);
                component.Visible = 'off';
            end
        end

        % Change theme
        function changeColors(obj, currentColors)
            selectMaskingNoiseLabel = obj.components('selectMaskingNoiseLabel');
            selectMaskingNoiseLabel.FontColor = currentColors.USER_LABEL_COLOR;

            noMaskingNoiseCheckBox = obj.components('noMaskingNoiseCheckBox');
            noMaskingNoiseCheckBox.FontColor = currentColors.USER_LABEL_COLOR;

            locatedNoiseCheckBox = obj.components('locatedNoiseCheckBox');
            locatedNoiseCheckBox.FontColor = currentColors.USER_LABEL_COLOR;

            diffusedNoiseCheckBox = obj.components('diffusedNoiseCheckBox');
            diffusedNoiseCheckBox.FontColor = currentColors.USER_LABEL_COLOR;

            numberLabel = obj.components('numberLabel');
            numberLabel.FontColor = currentColors.USER_LABEL_COLOR;

            numberBox = obj.components('numberBox');
            numberBox.FontColor = currentColors.USER_LABEL_COLOR;
            numberBox.BackgroundColor = currentColors.USER_GUI_ELEM_COLOR_ONE;
        end

        % Callback for noMaskingNoiseCheckBox
        function onNoMaskingNoiseCheckBoxChanged(obj)
            noMaskingNoiseCheckBox = obj.components('noMaskingNoiseCheckBox');
            locatedNoiseCheckBox = obj.components('locatedNoiseCheckBox');
            diffusedNoiseCheckBox = obj.components('diffusedNoiseCheckBox');
            numberLabel = obj.components('numberLabel');
            numberBox = obj.components('numberBox');

            if noMaskingNoiseCheckBox.Value
                locatedNoiseCheckBox.Value = false;
                diffusedNoiseCheckBox.Value = false;
                locatedNoiseCheckBox.Enable = 'off';
                diffusedNoiseCheckBox.Enable = 'off';
                numberLabel.Enable = 'off';
                numberBox.Enable = 'off';
            else
                locatedNoiseCheckBox.Enable = 'on';
                diffusedNoiseCheckBox.Enable = 'on';
                numberLabel.Enable = 'on';
                numberBox.Enable = 'on';
                locatedNoiseCheckBox.Value = true;
            end
        end

        % Callback for locatedNoiseCheckBox
        function onLocatedNoiseCheckBoxChanged(obj)
            locatedNoiseCheckBox = obj.components('locatedNoiseCheckBox');
            diffusedNoiseCheckBox = obj.components('diffusedNoiseCheckBox');
            numberLabel = obj.components('numberLabel');
            numberBox = obj.components('numberBox');

            if locatedNoiseCheckBox.Value
                diffusedNoiseCheckBox.Value = false;
                numberLabel.Enable = 'on';
                numberBox.Enable = 'on';
            else
                diffusedNoiseCheckBox.Value = true; 
                numberLabel.Enable = 'off';
                numberBox.Enable = 'off';
            end
        end

        % Callback for diffusedNoiseCheckBox
        function onDiffusedNoiseCheckBoxChanged(obj)
            locatedNoiseCheckBox = obj.components('locatedNoiseCheckBox');
            diffusedNoiseCheckBox = obj.components('diffusedNoiseCheckBox');
            numberLabel = obj.components('numberLabel');
            numberBox = obj.components('numberBox');

            if diffusedNoiseCheckBox.Value
                locatedNoiseCheckBox.Value = false;
                numberLabel.Enable = 'off';
                numberBox.Enable = 'off';
            else
                locatedNoiseCheckBox.Value = true;
                numberLabel.Enable = 'on';
                numberBox.Enable = 'on';
            end
        end
    end
end
