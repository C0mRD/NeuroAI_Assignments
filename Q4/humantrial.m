sca; clear; clc;

KbName('UnifyKeyNames');

try
    % Setup Screen
    Screen('Preference', 'SkipSyncTests', 1); % remove later
    screenNumber = max(Screen('Screens'));
    gray = [128 128 128];

    [window, windowRect] = Screen('OpenWindow', screenNumber, gray);
    [xCenter, yCenter] = RectCenter(windowRect);

    % Fixation Cross
    fixCrossDimPix = 40;
    lineWidthPix = 4;
    coords = [-fixCrossDimPix fixCrossDimPix 0 0; 0 0 -fixCrossDimPix fixCrossDimPix];

    % Load Image
    dogImg = imread('/Users/sujoynath/Downloads/dog.jpeg');
    dogTexture = Screen('MakeTexture', window, dogImg);

    % Keys
    spaceKey = KbName('SPACE');
    escapeKey = KbName('ESCAPE');

    % Trials
    numTrials = 10;
    results = table('Size',[numTrials 2], ...
        'VariableTypes',{'double','double'}, ...
        'VariableNames',{'Trial','ReactionTime'});

    % Setup keyboard queue (better than KbCheck)
    KbQueueCreate;
    KbQueueStart;

    for trial = 1:numTrials

        % Fixation
        Screen('FillRect', window, gray);
        Screen('DrawLines', window, coords, lineWidthPix, [0 0 0], [xCenter yCenter]);
        Screen('Flip', window);
        WaitSecs(3);

        % Stimulus
        Screen('DrawTexture', window, dogTexture);
        startTime = Screen('Flip', window);

        KbQueueFlush;

        responded = false;

        while ~responded
            [pressed, firstPress] = KbQueueCheck;

            if pressed
                if firstPress(spaceKey) > 0
                    rt = firstPress(spaceKey) - startTime;
                    results.Trial(trial) = trial;
                    results.ReactionTime(trial) = rt;
                    responded = true;

                elseif firstPress(escapeKey) > 0
                    disp('Experiment terminated by user.');
                    sca;
                    KbQueueRelease;
                    return;
                end
            end
        end

        WaitSecs(1);
    end

    % Compute Average
    avgRT = mean(results.ReactionTime, 'omitnan');

    disp(results);
    fprintf('Average Reaction Time: %.4f seconds\n', avgRT);

    % Save Data
    saveFolder = '/Users/sujoynath/Documents/matlab-files'; % your desired folder
    filename = fullfile(saveFolder, ['results_' datestr(now,'yyyymmdd_HHMMSS') '.csv']);
    writetable(results, filename);

    fprintf('Results saved to %s\n', filename);

    % Cleanup
    sca;
    KbQueueRelease;

catch ME
    sca;
    KbQueueRelease;
    rethrow(ME);
end