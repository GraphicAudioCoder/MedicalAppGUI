classdef EnvironmentPanel < handle
    properties
        mainWindow
        components
        controller
    end
    
    methods
        function obj = EnvironmentPanel(mainWindow, controller)
            NamesFonts;
            theme = ThemeManager();

            obj.components = containers.Map();
            obj.mainWindow = mainWindow;
            obj.controller = controller;

            % Main Scrollable Panel
            obj.components('mainPanel') = uipanel('Parent', mainWindow, ...
                'Position', [USER_PANEL_X_START, 100, 1060 - USER_PANEL_X_START, 550], ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                'Units', 'pixels'); 

            % Scrollable Area inside the mainPanel
            scrollableArea = uigridlayout(obj.components('mainPanel'), ...
                'Scrollable', 'on', ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                'RowHeight', repmat({250}, 1, 10), ... % Height of 250 pixels for 10 rows
                'ColumnWidth', {'1x'}); % One expandable column

            % Read all scenes
            [numScenes, sceneNames, fileNames] = obj.controller.readAllScenes(); % Use the controller property

            % Panels
            for i = 1:numScenes
                panelName = sprintf('panel%d', i);
                panel = uipanel('Parent', scrollableArea, ...
                    'BackgroundColor', theme.USER_PANEL_COLOR, ...
                    'FontSize', NEXT_BTN_FONT_SIZE, ...
                    'FontName', MAIN_FONT, ...
                    'Units', 'pixels');
                obj.components(panelName) = panel;

                panel.Layout.Row = i;
                panel.Layout.Column = 1;

                labelText = sceneNames{i};
                
                % Determine the image path (either PNG or JPG)
                pngPath = fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileNames{i}, '/', fileNames{i}, '_plan.png']);
                jpgPath = fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileNames{i}, '/', fileNames{i}, '_plan.jpg']);
                if exist(pngPath, 'file')
                    imgPath = pngPath;
                elseif exist(jpgPath, 'file')
                    imgPath = jpgPath;
                else
                    imgPath = ''; % Default to empty if no image found
                end

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
                    'Position', [20, 113, 200, 30]);
                obj.components(labelName) = label;  

                % Button with image for the center of the panel
                imgButtonName = sprintf('imgButton%d', i);
                imgButton = uibutton(panel, 'push', ...
                'Text', '', ...
                'Icon', imgPath, ...
                'Position', [250, 10, 230, 230], ...
                'ButtonPushedFcn', @(btn, event) obj.onImageButtonPushed(btn, i, fileNames{i}));
                obj.components(imgButtonName) = imgButton;  

                % Load the scene .mat file to get acousticalSpecs
                sceneData = load(fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileNames{i}, '/', fileNames{i}, '.mat']));
                acousticalSpecs = sceneData.acousticalSpecs;

                % Text area and Label for the right side of the panel
                textAreaLabel = uilabel(panel, ...
                    'Text', 'Acoustical specs:', ...
                    'FontSize', 12, ...
                    'FontName', MAIN_FONT, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'HorizontalAlignment', 'left', ...
                    'FontWeight', 'bold', ...
                    'Position', [500, 205, 200, 30]);

                textArea = uitextarea(panel, ...
                    'Value', acousticalSpecs, ...
                    'FontSize', SPECS_FONT_SIZE, ...
                    'FontName', SPECS_FONT, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'BackgroundColor', theme.USER_GUI_ELEM_COLOR_ONE, ...
                    'Editable', 'off', ...
                    'Position', [500, 100, 230, 100]);

                % Store the text area label and text area components in the map
                obj.components(sprintf('textAreaLabel%d', i)) = textAreaLabel;
                obj.components(sprintf('textArea%d', i)) = textArea;

                % Select button
                selectButton = uibutton(panel, 'push', ...
                    'Text', 'Select', ...
                    'FontName', MAIN_FONT, ...
                    'BackgroundColor', theme.USER_CURRENT_TABS_COLOR, ...
                    'FontColor', theme.USER_LABEL_COLOR, ...
                    'FontSize', SELECT_BTN_FONT_SIZE, ...
                    'Position', [630, 20, 100, 30], ...
                    'FontWeight', 'bold', ...
                    'ButtonPushedFcn', @(src, event) obj.onSelectSceneButtonPushed(i));

                % Store the button component
                obj.components(sprintf('selectButton%d', i)) = selectButton;
            end

             % Selected Environment Label
            selectedLabel = uilabel(obj.mainWindow, ...
                'Text', 'Selected environment: ', ...
                'Position', [USER_PANEL_X_START + 20, 40, 500, 30], ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('selectedLabel') = selectedLabel;
        end

        % Listener callback for the "Select" buttons
        function onSelectSceneButtonPushed(obj, panelIndex)

            selectedLabel = obj.components('selectedLabel');
            [~, sceneNames, ~] = obj.controller.readAllScenes();

            if panelIndex <= numel(sceneNames)
                selectedLabel.Text = ['Selected environment: ', sceneNames{panelIndex}];
            end    
            
            if ~isempty(obj.controller.currentScene)
                oldScene = obj.controller.currentScene.sceneName;
            else 
                oldScene = '';
            end
            
            obj.controller.onSelectSceneButtonPushed(panelIndex);
            obj.controller.listenerPanel.updateListeners(obj.controller.currentScene);
            
            % Reset the selected listener label
            listenerSelectedLabel = obj.controller.listenerPanel.components('selectedLabel');
            if ~strcmp(oldScene, obj.controller.currentScene.sceneName)
                listenerSelectedLabel.Text = 'Selected listener: ';
                obj.controller.targetSpeakerPanel.clearPanels();
            end
        end

        % Callback for the image button press
        function onImageButtonPushed(obj, btn, imgIndex, fileName)
            % Determine the file extension of the current image
            [~, ~, ext] = fileparts(btn.Icon);
            
            % Set the image paths based on the current extension
            if strcmp(ext, '.png')
                imgPaths = {
                    fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileName, '/', fileName, '_plan.png']), ...
                    fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileName, '/', fileName, '_photo.png']), ...
                    fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileName, '/', fileName, '_3d.png'])
                };
            else
                imgPaths = {
                    fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileName, '/', fileName, '_plan.jpg']), ...
                    fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileName, '/', fileName, '_photo.jpg']), ...
                    fullfile(fileparts(mfilename('fullpath')), ['../../scenes/', fileName, '/', fileName, '_3d.jpg'])
                };
            end
            
            if isempty(imgPaths)
                disp('Error: imgPaths is empty.');
                return;
            end
            
            currentIcon = btn.Icon;
            nextIndex = find(strcmp(currentIcon, imgPaths), 1) + 1;
            if isempty(nextIndex)
                nextIndex = 1;
            end

            if nextIndex > numel(imgPaths)
                nextIndex = 1;
            end
            
            btn.Icon = imgPaths{nextIndex};
        end

        % Sets the visibility of all components
        function setVisibility(obj, visibility)
            keys = obj.components.keys;
            for i = 1:length(keys)
                componentName = keys{i};
                component = obj.components(componentName);
                if visibility
                    component.Visible = 'on';
                else
                    component.Visible = 'off';
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
            mainPanel = obj.components('mainPanel');
            mainPanel.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;

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
                    component.BackgroundColor = currentColors.USER_GUI_ELEM_COLOR_ONE;
                    component.FontColor = currentColors.USER_LABEL_COLOR;
                end

                if isa(component, 'matlab.ui.control.Button')
                    component.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;
                    component.FontColor = currentColors.USER_LABEL_COLOR;
                end
            end
        end

        function onRightClick(obj, src, event)
            % mousePos = get(src, 'Currentpoint');
        end
    end
end
