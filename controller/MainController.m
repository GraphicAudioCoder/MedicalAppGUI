% /controller/MainController.m

classdef MainController < handle
    properties 
        status
        mainWindow
        currentPatient
        currentScene

        patientPanel
        environmentPanel
        listenerPanel
        targetSpeakerPanel
        maskingNoisePanel
        testSettingsPanel
    end
    
    methods
        % Starts the main application
        function obj = MainController()
            obj.status = 0;
            obj.mainWindow = MainWindow(obj);
            disp('Run...');
        end

        % Create a new patient file (MAT file)
        function createNewPatientFile(obj, filePath)            
            [~, fileName, ~] = fileparts(filePath);
            patientData.filePath = filePath;
            patientData.id = fileName;
            patientData.creationDate = datetime('now');
            
            try
                save(filePath, 'patientData');
                obj.currentPatient = PatientData(filePath, fileName, patientData.creationDate, true);
            catch
                disp('Error: Unable to create the .mat file.');
            end
        end
        
        % Save Patient and Data
        function success = saveCurrentPatient(obj, name, surname, dob, notes)
            success = false;
            
            if ~isempty(obj.currentPatient)
                try
                    obj.currentPatient.name = name;
                    obj.currentPatient.surname = surname;
                    obj.currentPatient.dateOfBirth = dob;

                    if ~isempty(notes)
                        obj.currentPatient = obj.currentPatient.updateNotes(notes);
                    end

                    % Prepare patient data for saving
                    patientData.filePath = obj.currentPatient.filePath;
                    patientData.id = obj.currentPatient.id;
                    patientData.name = obj.currentPatient.name;
                    patientData.surname = obj.currentPatient.surname;
                    patientData.dateOfBirth = obj.currentPatient.dateOfBirth;
                    patientData.creationDate = obj.currentPatient.creationDate;
                    patientData.history = obj.currentPatient.history;

                    % Save the patient data
                    try
                        save(obj.currentPatient.filePath, 'patientData');
                        success = true;
                    catch
                        disp('Error: Unable to save the patient data.');
                    end
                catch ME
                    disp(['Error while saving patient: ', ME.message]);
                end
            end
        end

        % Add a new note to the current patient
        function obj = addNoteToPatient(obj, noteText)
            if isempty(obj.currentPatient)
                error('No patient to add notes to');
            end
            obj.currentPatient = obj.currentPatient.addNote(noteText);
            disp('Note added to patient history');
        end

        function [name, surname, dob, prevHistory, currHistory] = openExistingPatientFile(obj, filePath)
            try
                fileData = load(filePath);
                patientData = fileData.patientData;
                obj.currentPatient = PatientData(filePath, patientData.id, patientData.creationDate, false);
                obj.currentPatient.name = patientData.name;
                obj.currentPatient.surname = patientData.surname;
                obj.currentPatient.dateOfBirth = patientData.dateOfBirth;
                obj.currentPatient.history = patientData.history;

                % Remove empty notes from history
                obj.currentPatient = obj.currentPatient.removeEmptyNotes();

                % Print the history
                disp('Current patient history:');
                for i = 1:length(obj.currentPatient.history)
                    disp(['Date: ', char(obj.currentPatient.history(i).date), ', Text: ', obj.currentPatient.history(i).text]);
                end

                [prevHistory, currHistory] = obj.currentPatient.getSplitHistory();
                name = obj.currentPatient.name;
                surname = obj.currentPatient.surname;
                dob = obj.currentPatient.dateOfBirth;
            catch
                disp('Error: Unable to open the .mat file.');
            end
        end

        % Reads all scenes
        function [numScenes, sceneNames, fileNames] = readAllScenes(obj)            
            scenesPath = fullfile(fileparts(mfilename('fullpath')), '../scenes');
            sceneDirs = dir(scenesPath);
            sceneDirs = sceneDirs([sceneDirs.isdir] & ~ismember({sceneDirs.name}, {'.', '..'}));
            numScenes = numel(sceneDirs);
            sceneNames = cell(1, numScenes);
            fileNames = cell(1, numScenes);
            
            for i = 1:numScenes
                sceneName = sceneDirs(i).name;
                sceneNames{i} = strrep(sceneName, '_', ' ');
                sceneNames{i} = regexprep(sceneNames{i}, '(^.)', '${upper($1)}');
                fileNames{i} = sceneName;
            end
        end

        % Listener callback for the "Select" buttons
        function onSelectSceneButtonPushed(obj, panelIndex)
            [~, sceneNames, fileNames] = obj.readAllScenes();

            if panelIndex <= numel(sceneNames)
                obj.currentScene = SceneData(fileNames{panelIndex}, sceneNames{panelIndex});
            end
        end

        function onSelectListenerButtonPushed(obj, panelIndex)
            obj.currentScene = obj.currentScene.setListenerNum(panelIndex);
        end

        function onSelectTargetButtonPushed(obj, panelIndex)
            obj.currentScene = obj.currentScene.setSelectedTarget(panelIndex);
        end
        
    end
end
