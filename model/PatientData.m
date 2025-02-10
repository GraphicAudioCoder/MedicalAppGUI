% /model/PatientData.m

classdef PatientData
    properties
        filePath
        id
        name
        surname
        dateOfBirth
        creationDate
        history
    end
    
    methods
        % Constructor
        function obj = PatientData(fullPath, fileName, creationDate, newNote)
            obj.filePath = fullPath;
            obj.id = fileName;
            obj.creationDate = creationDate;
            obj.history = [];
            if newNote
                obj = obj.addNotes('');
            end
        end

        % Add a new note to the patient's history
        function obj = addNotes(obj, noteText)
            currentDate = datetime('now', 'Format', 'yyyy-MM-dd');  
            currentDate = dateshift(currentDate, 'start', 'day');  

            newNote.date = currentDate;
            newNote.text = noteText;
            obj.history = [obj.history, newNote];
        end

        % Update last note to the patient's history
        function obj = updateNotes(obj, noteText)
            disp('History at the beginning of updateNotes:');
            for i = 1:length(obj.history)
            disp(['Date: ', char(obj.history(i).date), ', Text: ', obj.history(i).text]);
            end

            currentDate = datetime('now', 'Format', 'yyyy-MM-dd');  
            currentDate = dateshift(currentDate, 'start', 'day');  
            
            if ~isempty(obj.history)
            obj.history(end).date = currentDate;
            obj.history(end).text = noteText;
            else
            newNote.date = currentDate;
            newNote.text = noteText;
            obj.history = [obj.history, newNote];
            end

            disp('History at the end of updateNotes:');
            for i = 1:length(obj.history)
            disp(['Date: ', char(obj.history(i).date), ', Text: ', obj.history(i).text]);
            end
        end

        % Add an empty note with the current date
        function obj = addEmptyNote(obj)
            currentDate = datetime('now', 'Format', 'yyyy-MM-dd');
            currentDate = dateshift(currentDate, 'start', 'day');

            newNote.date = currentDate;
            newNote.text = '';
            obj.history = [obj.history, newNote];
        end

        % Remove all history entries with empty or whitespace-only text
        function obj = removeEmptyNotes(obj)
            newHistory = repmat(struct('date', [], 'text', []), length(obj.history), 1);
            count = 0;
            for i = 1:length(obj.history)
                if ~isempty(strtrim(obj.history(i).text))
                    count = count + 1;
                    newHistory(count) = obj.history(i);
                    disp(size(obj.history(i).text));
                    disp(obj.history(i).text);
                    % if isempty(obj.history(i).text)
                    %     disp('empty note found');
                    % end
                end
            end
            newHistory = newHistory(1:count);
            obj.history = newHistory;
        end

        % Save method for preparing the data
        function patientData = save(obj)
            lastText = obj.history(end).text; 

            if isempty(cell2mat(lastText))
                obj.history(end) = [];
            end

            patientData.filePath = obj.filePath;
            patientData.id = obj.id;
            patientData.name = obj.name;
            patientData.surname = obj.surname;
            patientData.dateOfBirth = obj.dateOfBirth;
            patientData.creationDate = obj.creationDate;
            patientData.history = obj.history;
        end

        % Get today's note
        function noteText = getTodayNote(obj)
            currentDate = datetime('now', 'Format', 'yyyy-MM-dd');
            
            noteText = '';
            for i = 1:length(obj.history)
                if isequal(obj.history{i}.date, currentDate)
                    noteText = obj.history{i}.text;
                    return;
                end
            end
        end

        % Get today's note and previous notes
        function [prevHistory, currHistory] = getSplitHistory(obj, numDashes)
            if nargin < 2
                numDashes = 50;
            end
            
            prevHistory = '';
            currHistory = '';
            
            for i = 1:length(obj.history)
                noteDate = dateshift(obj.history(i).date, 'start', 'day');
                noteText = obj.history(i).text{1};

                noteDateStr = string(noteDate, 'dd-MM-yyyy');
                dashes = repmat('-', 1, numDashes);

                prevHistory = sprintf('%s%s %s %s\n%s\n\n', prevHistory, dashes, noteDateStr, dashes, noteText);
            end
        end
    end
end
