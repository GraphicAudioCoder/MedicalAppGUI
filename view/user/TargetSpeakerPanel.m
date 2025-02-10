% /view/user/TargetSpeakerPanel.m

classdef TargetSpeakerPanel < handle
    properties
        mainWindow
        components
        controller
        scrollableArea
    end
    
    methods
        function obj = TargetSpeakerPanel(mainWindow, controller)
            NamesFonts;
            theme = ThemeManager();

            obj.mainWindow = mainWindow;
            obj.components = containers.Map();
            obj.controller = controller;

            selectTargetLabel = uilabel(obj.mainWindow, ...
                'Text', 'Select the target speaker:', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', ...
                'Position', [475, 600, 400, 30]);
            obj.components('selectTargetLabel') = selectTargetLabel;  

            % Main Scrollable Panel
            obj.components('mainPanel') = uipanel('Parent', mainWindow, ...
                'Position', [USER_PANEL_X_START, 100, 1060 - USER_PANEL_X_START, 480], ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                'Units', 'pixels'); 

            % Scrollable Area inside the mainPanel
            obj.scrollableArea = uigridlayout(obj.components('mainPanel'), ...
                'Scrollable', 'on', ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                'RowHeight', repmat({400}, 1, 10), ... % Height of 250 pixels for 10 rows
                'ColumnWidth', {'1x'}); % One expandable column

            % Selected Target Label
            selectedLabel = uilabel(obj.mainWindow, ...
                'Text', 'Selected Target: ', ...
                'Position', [USER_PANEL_X_START + 20, 40, 500, 30], ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('selectedLabel') = selectedLabel;
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

         % Update listeners based on the selected scene
        function updateTargetSpeaker(obj, currentScene, numListeners)
            NamesFonts;
            theme = ThemeManager();

            % Clear existing panels
            obj.clearPanels();

            % Get listener images
            targetPath = fullfile(currentScene.scenePath, 'targets');
            targetFilesPng = dir(fullfile(targetPath, sprintf('%s_listener_%d_target_*.png', currentScene.sceneFileName, obj.controller.currentScene.listenerNum)));
            targetFilesJpg = dir(fullfile(targetPath, sprintf('%s_listener_%d_target_*.jpg', currentScene.sceneFileName, obj.controller.currentScene.listenerNum)));
            targetFiles = [targetFilesPng; targetFilesJpg];
            numTargets = numel(targetFiles);   

            imgOffset = 30;
            ampY = 300;
            % Generate new panels based on the number of targets
            for i = 1:numTargets
                panelName = sprintf('panel%d', i);
                panel = uipanel('Parent', obj.scrollableArea, ...
                    'BackgroundColor', theme.USER_PANEL_COLOR, ...
                    'FontSize', NEXT_BTN_FONT_SIZE, ...
                    'FontName', MAIN_FONT, ...
                    'Units', 'pixels');
                obj.components(panelName) = panel;

                panel.Layout.Row = i;
                panel.Layout.Column = 1;

                labelText = sprintf('Target %d', i);
                imgPath = fullfile(targetPath, targetFiles(i).name);

                % Label for the left side of the panel
                labelName = sprintf('label%d', i);
                label = uilabel(panel, ...
                    'Text', labelText, ...
                    'FontSize', 12, ...
                    'FontSize', NEXT_BTN_FONT_SIZE, ...
                    'FontName', MAIN_FONT, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'HorizontalAlignment', 'left', ...
                    'FontWeight', 'bold', ...
                    'Position', [20, 187, 200, 30]);
                obj.components(labelName) = label;  

                % Image for the center of the panel with offset
                imgName = sprintf('img%d', i);
                img = uiimage(panel, ...
                    'ImageSource', imgPath, ...
                    'Position', [120 - imgOffset, 10, 490, 380]);
                obj.components(imgName) = img;  

                % Checkbutton with text for the right side of the panel
                checkButtonName = sprintf('checkButton%d', i);
                checkButton = uicheckbox(panel, ...
                    'Text', ' Amplified', ...
                    'FontSize', 12, ...
                    'FontSize', NEXT_BTN_FONT_SIZE, ...
                    'FontName', MAIN_FONT, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'Position', [550, ampY, 200, 30], ...
                    'Tooltip', 'Check to amplify the target speaker');
                obj.components(checkButtonName) = checkButton;  

                % TextArea for the right side of the panel
                textAreaName = sprintf('textArea%d', i);
                textArea = uitextarea(panel, ...
                    'Value', sprintf('Level: %d dBA', i * 10), ...
                    'FontSize', SPECS_FONT_SIZE, ...
                    'FontName', SPECS_FONT, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'BackgroundColor', theme.USER_PANEL_COLOR, ...
                    'Editable', 'off', ...
                    'Position', [550, ampY - 160, 180, 130]);
                obj.components(textAreaName) = textArea;

                % Select button for the right side of the panel
                selectButtonName = sprintf('selectButton%d', i);
                selectButton = uibutton(panel, ...
                    'Text', 'Select', ...
                    'FontName', MAIN_FONT, ...
                    'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'FontSize', SELECT_BTN_FONT_SIZE, ...
                    'Position', [630, 20, 100, 30], ...
                    'FontWeight', 'bold', ...
                    'ButtonPushedFcn', @(btn, event) obj.onSelectTargetButtonPushed(i));
                obj.components(selectButtonName) = selectButton;
            end
        end

        function onSelectTargetButtonPushed(obj, panelIndex)
            obj.controller.onSelectTargetButtonPushed(panelIndex);
            selectedLabel = obj.components('selectedLabel');
            selectedLabel.Text = sprintf('Selected Target: %d', panelIndex);
        end
        
        % Clear all panels
        function clearPanels(obj)
            keys = obj.components.keys;
            for i = 1:length(keys)
                componentName = keys{i};
                if startsWith(componentName, 'panel') || startsWith(componentName, 'img') || startsWith(componentName, 'selectButton')
                    component = obj.components(componentName);
                    if isvalid(component)
                        delete(component);
                    end
                    remove(obj.components, componentName);
                end
            end
            selectedLabel = obj.components('selectedLabel');
            selectedLabel.Text = sprintf('Selected Target: ');
        end

        % Change theme
        function changeColors(obj, currentColors)
            mainPanel = obj.components('mainPanel');
            mainPanel.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;

            selectTargetLabel = obj.components('selectTargetLabel');
            selectTargetLabel.FontColor = currentColors.USER_LABEL_COLOR;

            scrollableArea = mainPanel.Children(1);
            if isa(scrollableArea, 'matlab.ui.container.GridLayout')
                scrollableArea.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;
            end

            keys = obj.components.keys;
            for i = 1:length(keys)
                componentName = keys{i};
                component = obj.components(componentName);
                
                if isa(component, 'matlab.ui.container.Panel') && ~strcmp(componentName, 'mainPanel')
                    component.BackgroundColor = currentColors.USER_PANEL_COLOR;
                end

                if isa(component, 'matlab.ui.control.Label')
                    component.FontColor = currentColors.USER_LABEL_COLOR;
                end

                if isa(component, 'matlab.ui.control.TextArea')
                    component.BackgroundColor = currentColors.USER_PANEL_COLOR;
                    component.FontColor = currentColors.USER_LABEL_COLOR;
                end

                if isa(component, 'matlab.ui.control.Button')
                    component.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;
                    component.FontColor = currentColors.USER_LABEL_COLOR;
                end

                if isa(component, 'matlab.ui.control.CheckBox')
                    component.FontColor = currentColors.USER_LABEL_COLOR;
                end
            end
        end
    end
end
