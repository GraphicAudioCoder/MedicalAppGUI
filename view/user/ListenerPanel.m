% /view/user/ListenerPanel.m

classdef ListenerPanel < handle
    properties
        mainWindow
        components
        controller
        scrollableArea
    end
    
    methods
        function obj = ListenerPanel(mainWindow, controller)
            NamesFonts;
            theme = ThemeManager();

            obj.mainWindow = mainWindow;
            obj.components = containers.Map();
            obj.controller = controller;

            selectListenerPosLabel = uilabel(obj.mainWindow, ...
                'Text', 'Select the listener''s position:', ...
                'FontSize', 12, ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', ...
                'Position', [475, 600, 400, 30]);
            obj.components('selectListenerPosLabel') = selectListenerPosLabel;  

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

            % Selected Listener Label
            selectedLabel = uilabel(obj.mainWindow, ...
                'Text', 'Selected listener: ', ...
                'Position', [USER_PANEL_X_START + 20, 40, 500, 30], ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('selectedLabel') = selectedLabel;
        end

        % Sets the listener
        function onSelectListenerButtonPushed(obj, panelIndex) 
            obj.controller.onSelectListenerButtonPushed(panelIndex);
            selectedlabel = obj.components('selectedLabel');
            selectedlabel.Text = ['Selected listener: ', num2str(panelIndex)];

            % Save selected listener in the current scene
            obj.controller.currentScene.setSelectedListener(panelIndex);
            
            % Get listener nums
            listenerPath = fullfile(obj.controller.currentScene.scenePath, 'listeners');
            listenerDirs = dir(listenerPath);
            listenerDirs = listenerDirs(~[listenerDirs.isdir]);
            numListeners = numel(listenerDirs);

            % Clear and update target speaker panels
            obj.controller.targetSpeakerPanel.clearPanels();
            obj.controller.targetSpeakerPanel.updateTargetSpeaker(obj.controller.currentScene, numListeners);
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

        % Update listeners based on the selected scene
        function updateListeners(obj, currentScene)
            NamesFonts;
            theme = ThemeManager();

            % Clear existing panels
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

            % Get listener images
            listenerPath = fullfile(currentScene.scenePath, 'listeners');
            listenerFilesPng = dir(fullfile(listenerPath, '*.png'));
            listenerFilesJpg = dir(fullfile(listenerPath, '*.jpg'));
            listenerFiles = [listenerFilesPng; listenerFilesJpg];
            numListeners = numel(listenerFiles);

            % Set all components to invisible
            obj.setVisibility(false);

            % Generate new panels based on the number of listeners
            for i = 1:numListeners
                panelName = sprintf('panel%d', i);
                panel = uipanel('Parent', obj.scrollableArea, ...
                    'BackgroundColor', theme.USER_PANEL_COLOR, ...
                    'FontSize', NEXT_BTN_FONT_SIZE, ...
                    'FontName', MAIN_FONT, ...
                    'Units', 'pixels');
                obj.components(panelName) = panel;

                panel.Layout.Row = i;
                panel.Layout.Column = 1;

                labelText = sprintf('Listener %d', i);
                imgPath = fullfile(listenerPath, listenerFiles(i).name);

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

                % Image for the center of the panel
                imgName = sprintf('img%d', i);
                img = uiimage(panel, ...
                    'ImageSource', imgPath, ...
                    'Position', [120, 10, 490, 380]);
                obj.components(imgName) = img;  

                % Select button
                selectButton = uibutton(panel, 'push', ...
                    'Text', 'Select', ...
                    'FontName', MAIN_FONT, ...
                    'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'FontSize', SELECT_BTN_FONT_SIZE, ...
                    'Position', [630, 20, 100, 30], ...
                    'FontWeight', 'bold', ...
                    'ButtonPushedFcn', @(src, event) obj.onSelectListenerButtonPushed(i));

                % Store the button component
                obj.components(sprintf('selectButton%d', i)) = selectButton;
            end
        end

        % Change theme
        function changeColors(obj, currentColors)
            mainPanel = obj.components('mainPanel');
            mainPanel.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;

            selectListenerPosLabel = obj.components('selectListenerPosLabel');
            selectListenerPosLabel.FontColor = currentColors.USER_LABEL_COLOR;

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

                if isa(component, 'matlab.ui.control.Button')
                    component.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;
                    component.FontColor = currentColors.USER_LABEL_COLOR;
                end
            end
        end
    end
end
