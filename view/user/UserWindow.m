% /view/user/UserWindow.m

classdef UserWindow < handle
    properties
        mainWindow
        controller
        components
        onHeaderPanel
        onPatientTab
        onEnvironmentTab
        onListenerTab
        onTargetSpeakerTab
        onMaskingNoiseTab
        onTestSettingsTab

        currentTab
        realTabPosition
        tabPosition

        patientPanel
        environmentPanel
        listenerPanel
        targetSpeakerPanel
        maskingNoisePanel
        testSettingsPanel

        mouseDown
        mouseUp
    end
    methods
        function obj = UserWindow(mainWindow, controller)
            NamesFonts;
            theme = ThemeManager();

            obj.mainWindow = mainWindow;
            obj.controller = controller;
            obj.components = containers.Map();
            obj.onHeaderPanel = false;
            obj.onPatientTab = false;
            obj.onEnvironmentTab = false;
            obj.onListenerTab = false;
            obj.onTargetSpeakerTab = false;
            obj.onMaskingNoiseTab = false;
            obj.onTestSettingsTab = false;
            obj.mouseUp = true;
            obj.mouseDown = false;

            obj.tabPosition = 1;
            % Current advancement
            obj.realTabPosition = 1;

            figPosition = mainWindow.Position;
            
            % Header Panel
            headerPanel = uipanel(mainWindow, ...
                'Position', [10, 660, figPosition(3)-20, 50], ...
                'BackgroundColor', theme.USER_HEADER_COLOR);
            obj.components('headerPanel') = headerPanel;

            % User Panel
            userPanel = uipanel(mainWindow, ...
                'Position', [230, 10, 840, 650], ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR);
            obj.components('userPanel') = userPanel;

            % Theme Button
            if strcmp(theme.THEME, 'DARK')
                themeIconPath = fullfile(fileparts(mfilename('fullpath')), '../../assets/icons/sun.png');  
            else
                themeIconPath = fullfile(fileparts(mfilename('fullpath')), '../../assets/icons/moon.png');
            end
            themeButton = uibutton(mainWindow, ...
                'Position', [figPosition(3)-90, figPosition(4)-50, 30, 30], ...
                'Text', '', ...
                'FontSize', HELP_BTN_FONT_SIZE, ...
                'BackgroundColor', theme.THEME_BTN_COLOR, ...
                'ButtonPushedFcn', @(btn, event) obj.onThemeButtonPushed(btn), ...
                'Icon', themeIconPath, ...
                'IconAlignment', 'right');
            obj.components('themeButton') = themeButton;

            % Help Button
            helpIconPath = fullfile(fileparts(mfilename('fullpath')), '../../assets/icons/help.png');
            helpButton = uibutton(mainWindow, ...
                'Position', [figPosition(3)-50, figPosition(4)-50, 30, 30], ...
                'Text', '', ...
                'FontSize', HELP_BTN_FONT_SIZE, ...
                'BackgroundColor', theme.HELP_BTN_COLOR, ...
                'ButtonPushedFcn', @(btn, event)obj.onHelpButtonPushed(), ...
                'Icon', helpIconPath, ...
                'IconAlignment', 'right');
            obj.components('helpButton') = helpButton;

            % Tabbed Panels 
            obj.patientPanel = PatientPanel(mainWindow, controller);
            obj.environmentPanel = EnvironmentPanel(mainWindow, controller);
            obj.listenerPanel = ListenerPanel(mainWindow, controller);
            obj.targetSpeakerPanel = TargetSpeakerPanel(mainWindow, controller);
            obj.maskingNoisePanel = MaskingNoisePanel(mainWindow, controller);
            obj.testSettingsPanel = TestSettingsPanel(mainWindow);

            obj.controller.patientPanel = obj.patientPanel;
            obj.controller.environmentPanel = obj.environmentPanel;
            obj.controller.listenerPanel = obj.listenerPanel;
            obj.controller.targetSpeakerPanel = obj.targetSpeakerPanel;
            obj.controller.maskingNoisePanel = obj.maskingNoisePanel;
            obj.controller.testSettingsPanel = obj.testSettingsPanel;

            obj.hideTabPanels();
            obj.patientPanel.setVisibility(true);

            % Next Button
            nextButton = uibutton(mainWindow, ...
                'Position', [figPosition(3)-100, 30, 70, 40], ...
                'Text', 'Next', ...
                'FontSize', NEXT_BTN_FONT_SIZE, ...
                'BackgroundColor', theme.NEXT_BTN_COLOR, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', @(btn, event)obj.onNextButtonPushed());
            obj.components('nextButton') = nextButton;

            % User Mode Label
            userModeLabel = uilabel(mainWindow, ...
                'Text', 'USER MODE', ...
                'Position', [20, figPosition(4)-50, figPosition(3)*0.6, 30], ...
                'FontSize', MODE_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('userModeLabel') = userModeLabel;

            % Test Label
            testLabel = uilabel(mainWindow, ...
                'Text', 'TEST CONFIGURATION', ...
                'Position', [280, figPosition(4)-50, figPosition(3)*0.6, 30], ...
                'FontSize', MODE_FONT_SIZE, ...
                'FontName', MAIN_FONT, ...
                'FontColor', theme.USER_LABEL_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('testLabel') = testLabel;

            % Tab Panel
            tabPanel = uipanel(mainWindow, ...
                'Position', [10, 10, 220, figPosition(4)-70], ...
                'BackgroundColor', theme.USER_HEADER_COLOR);
            obj.components('tabPanel') = tabPanel;

            tabSize = 50;
            tabStartY = figPosition(4)-110;

            % Vertical Panel
            verticalPanel = uipanel(mainWindow, ...
                'Position', [230, 10, 50, figPosition(4)-70], ...
                'BackgroundColor', theme.USER_HEADER_COLOR);
            obj.components('verticalPanel') = verticalPanel;

            % Vertical Text Label
            verticalText = sprintf('P\nA\nT\nI\nE\nN\nT');
            verticalLabel = uilabel(verticalPanel, ...
                'Text', verticalText, ...
                'Position', [5, 127, 40, 400], ...
                'FontSize', TABS_FONT_SIZE, ...
                'FontName', TAB_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'center', ...
                'FontWeight', 'bold');
            obj.components('verticalLabel') = verticalLabel;
            
            % Patient Tab
            patientTab = uipanel(mainWindow, ...
                'Position', [10, tabStartY, 220, tabSize], ...
                'BackgroundColor', theme.USER_CURRENT_TABS_COLOR);
            obj.components('patientTab') = patientTab;
            obj.currentTab = patientTab;

            % Patient Label
            patientLabel = uilabel(mainWindow, ...
                'Text', 'Patient', ...
                'Position', [20, tabStartY + 10, 180, 30], ...
                'FontSize', TABS_FONT_SIZE, ...
                'FontName', TAB_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('patientLabel') = patientLabel;

            % Environment Tab
            environmentTab = uipanel(mainWindow, ...
                'Position', [10, tabStartY - tabSize, 220, tabSize], ...
                'BackgroundColor', theme.USER_TABS_COLOR);
            obj.components('environmentTab') = environmentTab;

            % Environment Label
            environmentLabel = uilabel(mainWindow, ...
                'Text', 'Environment', ...
                'Position', [20, tabStartY + 10 - tabSize, 180, 30], ...
                'FontSize', TABS_FONT_SIZE, ...
                'FontName', TAB_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('environmentLabel') = environmentLabel;

            % Listener Tab
            listenerTab = uipanel(mainWindow, ...
                'Position', [10, tabStartY - 2*tabSize, 220, tabSize], ...
                'BackgroundColor', theme.USER_TABS_COLOR);
            obj.components('listenerTab') = listenerTab;

            % Listener Label
            listenerLabel = uilabel(mainWindow, ...
                'Text', 'Listener', ...
                'Position', [20, tabStartY + 10 - 2*tabSize, 180, 30], ...
                'FontSize', TABS_FONT_SIZE, ...
                'FontName', TAB_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('listenerLabel') = listenerLabel;

            % Target Speaker Tab
            targetSpeakerTab = uipanel(mainWindow, ...
                'Position', [10, tabStartY - 3*tabSize, 220, tabSize], ...
                'BackgroundColor', theme.USER_TABS_COLOR);
            obj.components('targetSpeakerTab') = targetSpeakerTab;

            % Target Speaker Label
            targetSpeakerLabel = uilabel(mainWindow, ...
                'Text', 'Target Speaker', ...
                'Position', [20, tabStartY + 10 - 3*tabSize, 180, 30], ...
                'FontSize', TABS_FONT_SIZE, ...
                'FontName', TAB_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('targetSpeakerLabel') = targetSpeakerLabel;

            % Masking Noise Tab
            maskingNoiseTab = uipanel(mainWindow, ...
                'Position', [10, tabStartY - 4*tabSize, 220, tabSize], ...
                'BackgroundColor', theme.USER_TABS_COLOR);
            obj.components('maskingNoiseTab') = maskingNoiseTab;

            % Masking Noise Label
            maskingNoiseLabel = uilabel(mainWindow, ...
                'Text', 'Masking Noise', ...
                'Position', [20, tabStartY + 10 - 4*tabSize, 180, 30], ...
                'FontSize', TABS_FONT_SIZE, ...
                'FontName', TAB_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('maskingNoiseLabel') = maskingNoiseLabel;

            % Test Settings Tab
            testSettingsTab = uipanel(mainWindow, ...
                'Position', [10, tabStartY - 5*tabSize, 220, tabSize], ...
                'BackgroundColor', theme.USER_TABS_COLOR);
            obj.components('testSettingsTab') = testSettingsTab;

            % Test Settings Label
            testSettingsLabel = uilabel(mainWindow, ...
                'Text', 'Test Settings', ...
                'Position', [20, tabStartY + 10 - 5*tabSize, 180, 30], ...
                'FontSize', TABS_FONT_SIZE, ...
                'FontName', TAB_FONT, ...
                'FontColor', theme.USER_LABEL_TABS_COLOR, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            obj.components('testSettingsLabel') = testSettingsLabel;

            % Mouse Handlers
            obj.mainWindow.WindowButtonMotionFcn = @(src, event)obj.onMouseMove(src, event);
            obj.mainWindow.WindowButtonDownFcn = @(src, event)obj.onRightClick(src, event);
            obj.mainWindow.WindowButtonUpFcn = @(src, event)obj.onMouseUp(src, event);
        end
        
        % Mouse move handler for detecting tab hover
        function onMouseMove(obj, src, ~)
            NamesFonts;
            theme = ThemeManager();

            mousePos = get(src, 'Currentpoint');
            patientTab = obj.components('patientTab');
            environmentTab = obj.components('environmentTab');
            listenerTab = obj.components('listenerTab');
            targetSpeakerTab = obj.components('targetSpeakerTab');
            maskingNoiseTab = obj.components('maskingNoiseTab');
            testSettingsTab = obj.components('testSettingsTab');

            % Patient Tab hover detection
            patientPos = patientTab.Position;
            if ~obj.mouseDown && obj.realTabPosition >= 1
                if mousePos(1) >= patientPos(1) && mousePos(1) <= (patientPos(1) + patientPos(3)) && ...
                   mousePos(2) >= patientPos(2) && mousePos(2) <= (patientPos(2) + patientPos(4))
                    if obj.tabPosition ~= 1
                        patientTab.BackgroundColor = theme.USER_ON_TABS_COLOR;
                    end
                    obj.onPatientTab = true;
                else
                    if obj.tabPosition == 1
                        patientTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                    else
                        patientTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                    end
                    obj.onPatientTab = false;
                end
            end

            % Environment Tab hover detection
            environmentPos = environmentTab.Position;
            if ~obj.mouseDown && obj.realTabPosition >= 2
                if mousePos(1) >= environmentPos(1) && mousePos(1) <= (environmentPos(1) + environmentPos(3)) && ...
                   mousePos(2) >= environmentPos(2) && mousePos(2) <= (environmentPos(2) + environmentPos(4))
                    if obj.tabPosition ~= 2
                        environmentTab.BackgroundColor = theme.USER_ON_TABS_COLOR;
                    end
                    obj.onEnvironmentTab = true;
                else
                    if obj.tabPosition == 2
                        environmentTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                    else
                        environmentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                    end
                    obj.onEnvironmentTab = false;
                end
            end

            % Listener Tab hover detection
            listenerPos = listenerTab.Position;
            if ~obj.mouseDown && obj.realTabPosition >= 3
                if mousePos(1) >= listenerPos(1) && mousePos(1) <= (listenerPos(1) + listenerPos(3)) && ...
                   mousePos(2) >= listenerPos(2) && mousePos(2) <= (listenerPos(2) + listenerPos(4))
                    if obj.tabPosition ~= 3
                        listenerTab.BackgroundColor = theme.USER_ON_TABS_COLOR;
                    end
                    obj.onListenerTab = true;
                else
                    if obj.tabPosition == 3
                        listenerTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                    else
                        listenerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                    end
                    obj.onListenerTab = false;
                end
            end

            % Target Speaker Tab hover detection
            targetSpeakerPos = targetSpeakerTab.Position;
            if ~obj.mouseDown && obj.realTabPosition >= 4
                if mousePos(1) >= targetSpeakerPos(1) && mousePos(1) <= (targetSpeakerPos(1) + targetSpeakerPos(3)) && ...
                   mousePos(2) >= targetSpeakerPos(2) && mousePos(2) <= (targetSpeakerPos(2) + targetSpeakerPos(4))
                    if obj.tabPosition ~= 4
                        targetSpeakerTab.BackgroundColor = theme.USER_ON_TABS_COLOR;
                    end
                    obj.onTargetSpeakerTab = true;
                else
                    if obj.tabPosition == 4
                        targetSpeakerTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                    else
                        targetSpeakerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                    end
                    obj.onTargetSpeakerTab = false;
                end
            end

            % Masking Noise Tab hover detection
            maskingNoisePos = maskingNoiseTab.Position;
            if ~obj.mouseDown && obj.realTabPosition >= 5
                if mousePos(1) >= maskingNoisePos(1) && mousePos(1) <= (maskingNoisePos(1) + maskingNoisePos(3)) && ...
                   mousePos(2) >= maskingNoisePos(2) && mousePos(2) <= (maskingNoisePos(2) + maskingNoisePos(4))
                    if obj.tabPosition ~= 5
                        maskingNoiseTab.BackgroundColor = theme.USER_ON_TABS_COLOR;
                    end
                    obj.onMaskingNoiseTab = true;
                else
                    if obj.tabPosition == 5
                        maskingNoiseTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                    else
                        maskingNoiseTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                    end
                    obj.onMaskingNoiseTab = false;
                end
            end

            % Test Settings Tab hover detection
            testSettingsPos = testSettingsTab.Position;
            if ~obj.mouseDown && obj.realTabPosition >= 6
                if mousePos(1) >= testSettingsPos(1) && mousePos(1) <= (testSettingsPos(1) + testSettingsPos(3)) && ...
                   mousePos(2) >= testSettingsPos(2) && mousePos(2) <= (testSettingsPos(2) + testSettingsPos(4))
                    if obj.tabPosition ~= 6
                        testSettingsTab.BackgroundColor = theme.USER_ON_TABS_COLOR;
                    end
                    obj.onTestSettingsTab = true;
                else
                    if obj.tabPosition == 6
                        testSettingsTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                    else
                        testSettingsTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                    end
                    obj.onTestSettingsTab = false;
                end
            end
        end

        % Right click handler
        function onRightClick(obj, src, event)
            NamesFonts;
            theme = ThemeManager();

            testLabel = obj.components('testLabel');
            verticalLabel = obj.components('verticalLabel');

            obj.mouseDown = true;
            obj.mouseUp = false;

            if obj.onPatientTab && obj.tabPosition ~= 1
                % testLabel.Text = 'Test Configuration - Patient';
                verticalLabel.Text  = sprintf('P\nA\nT\nI\nE\nN\nT');
                obj.currentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                patientTab = obj.components('patientTab');
                patientTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                obj.currentTab = patientTab;
                obj.tabPosition = 1;
                obj.hideTabPanels();
                obj.patientPanel.setVisibility(true);
            elseif obj.onEnvironmentTab && obj.tabPosition ~= 2
                % testLabel.Text = 'Test Configuration - Environment';
                verticalLabel.Text = sprintf('E\nN\nV\nI\nR\nO\nN\nM\nE\nN\nT');
                obj.currentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                environmentTab = obj.components('environmentTab');
                environmentTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                obj.currentTab = environmentTab;
                obj.tabPosition = 2;
                obj.hideTabPanels();
                obj.environmentPanel.setVisibility(true);
            elseif obj.onListenerTab && obj.tabPosition ~= 3
                % testLabel.Text = 'Test Configuration - Listener';
                verticalLabel.Text = sprintf('L\nI\nS\nT\nE\nN\nE\nR');
                obj.currentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                listenerTab = obj.components('listenerTab');
                listenerTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                obj.currentTab = listenerTab;
                obj.tabPosition = 3;
                obj.hideTabPanels();
                obj.listenerPanel.setVisibility(true);
            elseif obj.onTargetSpeakerTab && obj.tabPosition ~= 4
                % testLabel.Text = 'Test Configuration - Target Speaker';
                verticalLabel.Text = sprintf('T\nA\nR\nG\nE\nT\n\nS\nP\nE\nA\nK\nE\nR');
                obj.currentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                targetSpeakerTab = obj.components('targetSpeakerTab');
                targetSpeakerTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                obj.currentTab = targetSpeakerTab;
                obj.tabPosition = 4;
                obj.hideTabPanels();
                obj.targetSpeakerPanel.setVisibility(true);
            elseif obj.onMaskingNoiseTab && obj.tabPosition ~= 5
                % testLabel.Text = 'Test Configuration - Masking Noise';
                verticalLabel.Text = sprintf('M\nA\nS\nK\nI\nN\nG\n\nN\nO\nI\nS\nE');
                obj.currentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                maskingNoiseTab = obj.components('maskingNoiseTab');
                maskingNoiseTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                obj.currentTab = maskingNoiseTab;
                obj.tabPosition = 5;
                obj.hideTabPanels();
                obj.maskingNoisePanel.setVisibility(true);
            elseif obj.onTestSettingsTab && obj.tabPosition ~= 6
                % testLabel.Text = 'Test Configuration - Test Settings';
                verticalLabel.Text = sprintf('T\nE\nS\nT\n\nS\nE\nT\nT\nI\nN\nG\nS');
                obj.currentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                testSettingsTab = obj.components('testSettingsTab');
                testSettingsTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
                obj.currentTab = testSettingsTab;
                obj.tabPosition = 6;
                obj.hideTabPanels();
                obj.testSettingsPanel.setVisibility(true);
            end

            if obj.tabPosition == 1
                obj.patientPanel.onRightClick(src, event)
            elseif obj.tabPosition == 2
                obj.environmentPanel.onRightClick(src, event)
            end
        end

        % Mouse release handler
        function onMouseUp(obj, src, event)
            NamesFonts;
            theme = ThemeManager();

            obj.mouseDown = false;
            obj.mouseUp = true;
        end

        % Next button listener
        function onNextButtonPushed(obj)
            NamesFonts;
            theme = ThemeManager();

            testLabel = obj.components('testLabel');
            verticalLabel = obj.components('verticalLabel');

            patientTab = obj.components('patientTab');
            environmentTab = obj.components('environmentTab');
            listenerTab = obj.components('listenerTab');
            targetSpeakerTab = obj.components('targetSpeakerTab');
            maskingNoiseTab = obj.components('maskingNoiseTab');
            testSettingsTab = obj.components('testSettingsTab');
            
            % Check if the environment is selected
            selectedEnvironmentLabel = obj.controller.environmentPanel.components('selectedLabel');
            if obj.tabPosition == 2 && isempty(strtrim(strrep(selectedEnvironmentLabel.Text, 'Selected environment: ', '')))
                return; % Do not proceed if the environment is not selected
            end

            % Check if the listener is selected
            selectedListenerLabel = obj.controller.listenerPanel.components('selectedLabel');
            if obj.tabPosition == 3 && isempty(strtrim(strrep(selectedListenerLabel.Text, 'Selected listener: ', '')))
                return; % Do not proceed if the listener is not selected
            end

            % Check if the target speaker is selected
            selectedTargetLabel = obj.controller.targetSpeakerPanel.components('selectedLabel');
            if obj.tabPosition == 4 && isempty(strtrim(strrep(selectedTargetLabel.Text, 'Selected Target: ', '')))
                return; % Do not proceed if the target speaker is not selected
            end

            if obj.tabPosition == 1
                patientTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;

                obj.currentTab = environmentTab;
                obj.realTabPosition = max(obj.realTabPosition, 2);
                obj.tabPosition = 2;
                % testLabel.Text = 'Test Configuration - Environment';
                verticalLabel.Text = sprintf('E\nN\nV\nI\nR\nO\nN\nM\nE\nN\nT');
                obj.hideTabPanels();
                obj.environmentPanel.setVisibility(true);
                environmentTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
            elseif obj.tabPosition == 2
                patientTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                environmentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;

                obj.currentTab = listenerTab;
                obj.realTabPosition = max(obj.realTabPosition, 3);
                obj.tabPosition = 3;
                % testLabel.Text = 'Test Configuration - Listener';
                verticalLabel.Text = sprintf('L\nI\nS\nT\nE\nN\nE\nR');
                obj.hideTabPanels();
                obj.listenerPanel.setVisibility(true);
                listenerTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
            elseif obj.tabPosition == 3
                patientTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                environmentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                listenerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;

                obj.currentTab = targetSpeakerTab;
                obj.realTabPosition = max(obj.realTabPosition, 4);
                obj.tabPosition = 4;
                % testLabel.Text = 'Test Configuration - Target Speaker';
                verticalLabel.Text = sprintf('T\nA\nR\nG\nE\nT\n\nS\nP\nE\nA\nK\nE\nR');
                obj.hideTabPanels();
                obj.targetSpeakerPanel.setVisibility(true);
                targetSpeakerTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
            elseif obj.tabPosition == 4
                patientTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                environmentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                listenerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                targetSpeakerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                
                obj.currentTab = maskingNoiseTab;
                obj.realTabPosition = max(obj.realTabPosition, 5);
                obj.tabPosition = 5;
                % testLabel.Text = 'Test Configuration - Masking Noise';
                verticalLabel.Text = sprintf('M\nA\nS\nK\nI\nN\nG\n\nN\nO\nI\nS\nE');
                obj.hideTabPanels();
                obj.maskingNoisePanel.setVisibility(true);
                maskingNoiseTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
            elseif obj.tabPosition == 5
                patientTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                environmentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                listenerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                targetSpeakerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                maskingNoiseTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;

                obj.currentTab = testSettingsTab;
                obj.realTabPosition = max(obj.realTabPosition, 6);
                obj.tabPosition = 6;
                % testLabel.Text = 'Test Configuration - Test Settings';
                verticalLabel.Text = sprintf('T\nE\nS\nT\n\nS\nE\nT\nT\nI\nN\nG\nS');
                obj.hideTabPanels();
                obj.testSettingsPanel.setVisibility(true);
                testSettingsTab.BackgroundColor = theme.USER_CURRENT_TABS_COLOR;
            elseif obj.tabPosition == 6
                patientTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                environmentTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                listenerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                targetSpeakerTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                maskingNoiseTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                testSettingsTab.BackgroundColor = theme.USER_COMPLETED_TABS_COLOR;
                
                obj.tabPosition = 7;
                testLabel.Text = 'Test Configuration';
                obj.hideTabPanels();
            end
        end

        % Theme button listener
        function onThemeButtonPushed(obj, btn)
            % Switch the theme
            theme = ThemeManager('switch');        
            currentColors = theme;
            
            % Update the theme icon
            if strcmp(theme.THEME, 'DARK')
                themeIconPath = fullfile(fileparts(mfilename('fullpath')), '../../assets/icons/sun.png');
            else
                themeIconPath = fullfile(fileparts(mfilename('fullpath')), '../../assets/icons/moon.png');
            end
            btn.Icon = themeIconPath;
            
            % Update the colors of various UI components
            obj.mainWindow.Color =  currentColors.BACKGROUND_COLOR;
            headerPanel = obj.components('headerPanel');
            verticalPanel = obj.components('verticalPanel');
            verticalPanel.BackgroundColor = currentColors.USER_HEADER_COLOR;
            headerPanel.BackgroundColor = currentColors.USER_HEADER_COLOR;
            userPanel = obj.components('userPanel');
            userPanel.BackgroundColor = currentColors.USER_CURRENT_TABS_COLOR;
            nextButton = obj.components('nextButton');
            nextButton.BackgroundColor = currentColors.NEXT_BTN_COLOR;
            nextButton.FontColor = currentColors.USER_LABEL_COLOR;
            userModeLabel = obj.components('userModeLabel');
            userModeLabel.FontColor = currentColors.USER_LABEL_COLOR;
            testLabel = obj.components('testLabel');
            testLabel.FontColor = currentColors.USER_LABEL_COLOR;
            tabPanel = obj.components('tabPanel');
            tabPanel.BackgroundColor = currentColors.USER_HEADER_COLOR;
            helpButton = obj.components('helpButton');
            helpButton.BackgroundColor = currentColors.HELP_BTN_COLOR;
            
            % Update the colors of tabs
            updateTabColor(obj, 'patientTab', currentColors.USER_CURRENT_TABS_COLOR);
            updateTabColor(obj, 'environmentTab', currentColors.USER_TABS_COLOR);
            updateTabColor(obj, 'listenerTab', currentColors.USER_TABS_COLOR);
            updateTabColor(obj, 'targetSpeakerTab', currentColors.USER_TABS_COLOR);
            updateTabColor(obj, 'maskingNoiseTab', currentColors.USER_TABS_COLOR);
            updateTabColor(obj, 'testSettingsTab', currentColors.USER_TABS_COLOR);
            
            event = struct('Source', obj.mainWindow);
            obj.onMouseMove(obj.mainWindow, event);

            % Update the labels of tabs
            updateTabLabelColor(obj, 'patientLabel', currentColors.USER_LABEL_TABS_COLOR);
            updateTabLabelColor(obj, 'environmentLabel', currentColors.USER_LABEL_TABS_COLOR);
            updateTabLabelColor(obj, 'listenerLabel', currentColors.USER_LABEL_TABS_COLOR);
            updateTabLabelColor(obj, 'targetSpeakerLabel', currentColors.USER_LABEL_TABS_COLOR);
            updateTabLabelColor(obj, 'maskingNoiseLabel', currentColors.USER_LABEL_TABS_COLOR);
            updateTabLabelColor(obj, 'testSettingsLabel', currentColors.USER_LABEL_TABS_COLOR);
            updateTabLabelColor(obj, 'verticalLabel', currentColors.USER_LABEL_TABS_COLOR);

            % Update patient colors
            obj.patientPanel.changeColors(currentColors);
            obj.environmentPanel.changeColors(currentColors);
            obj.listenerPanel.changeColors(currentColors);
            obj.targetSpeakerPanel.changeColors(currentColors);
            obj.maskingNoisePanel.changeColors(currentColors);
        end

        % Helper function to update the color of a tab
        function updateTabColor(obj, tabName, color)
            if isKey(obj.components, tabName)
                tab = obj.components(tabName);
                tab.BackgroundColor = color;
            end
        end
        
        % Helper function to update the color of a tab's label
        function updateTabLabelColor(obj, labelName, color)
            if isKey(obj.components, labelName)
                label = obj.components(labelName);
                label.FontColor = color;
            end
        end

        % Help button listener
        function onHelpButtonPushed(obj, btn)
        end

        % Set all tab panels to invisible
        function hideTabPanels(obj)
            obj.patientPanel.setVisibility(false);
            obj.environmentPanel.setVisibility(false);
            obj.listenerPanel.setVisibility(false);
            obj.targetSpeakerPanel.setVisibility(false);
            obj.maskingNoisePanel.setVisibility(false);
            obj.testSettingsPanel.setVisibility(false);
        end

        % Set all tab panels to visibile
        function showTabPanels(obj)
            obj.patientPanel.setVisibility(true);
            obj.environmentPanel.setVisibility(true);
            obj.listenerPanel.setVisibility(true);
            obj.targetSpeakerPanel.setVisibility(true);
            obj.maskingNoisePanel.setVisibility(true);
            obj.testSettingsPanel.setVisibility(true);
        end

        % Delete all components
        function delete(obj)
            componentNames = keys(obj.components);
            for i = 1:length(componentNames)
                component = obj.components(componentNames{i});
                if isvalid(component)
                    delete(component);
                end
            end
        end
    end
end
