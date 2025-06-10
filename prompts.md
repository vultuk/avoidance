# User Prompts Log

## Initial Request
Please work through the @todo.md list to create this game. If you need further information pelase refer to the @CLAUDE.md and @plan.md files.

## Workflow Instructions
Please commit and push after each important change

## Status Check 1
Git you commit and push?

## Build Request
Can you compile binaries at this stage and add them to github as a release?

## Android SDK Request
Please can you install the android SDK on this system for me

## Bug Report 1 (v1.0.0)
I've checked the game and 1. Running into particle wave doesn't end the game. 2. There should only ever be one particle wave on screen at once. Please fix this, commit, push and release a new version

## Todo Tracking Reminder
Please make sure you are checking off items in @todo.md as you go along

## Summary Request
Your task is to create a detailed summary of the conversation so far, in a format that could help a new AI assistant understand the context and continue the work. Include:

1. The primary request and intent
2. Key technical concepts and approaches
3. Important files and code sections
4. Any errors encountered and how they were resolved
5. The current state of the project
6. Any pending tasks or next steps

Please be thorough and include specific details that would be helpful for continuity.

## Continue Work
Please continue the conversation from where we left it off without asking the user any further questions. Continue with the last task that you were asked to work on.

## Wave Clarification
Just to note, it is possible to have 1 blue and 1 orange particle wave on screen at the same time in medium and above modes

## Release Reminder
You haven't created a release

## Bug Report 2 (v2.0.0)
Ok. Few bugs. 1. Medium mode. The game ends when the orange ship touches the blue particle wave. This is incorrect. The game should only end when a ship touches the wave ofit's own colour. 2. Shields should be attached to the ship, not positioned on the 'screen'. They should move with the ship and be the colour of the wave it protects from. e.g. The blue ship should have orange shields on the left and right, the orange ship should have blue shields on the top and bottom.

## Prompts Storage Request
Please store all of the prompts I give you in @prompts.md. Add all the previous prompts and then going forward every new prompt.

## Git Tracking Request
The prompts file should be added to git

## Bug Report 3 & Git Cleanup Request
It appears that only one particle wave now appears. When it goes off screen no further ones appear. This is happening on all modes of the game. Please also remove the large files from git and add a .gitignore to make sure it doesn't happen again. We need to keep everything visible on github

## Git Cleanup Request 2
Lets make sure that none of these zips, apks and release notes make it into git. And remove any that already exist

## New Release Build Request
Can you build a new release please. I don't think the one you just released was in fact new. Lets buuld a whole new one and double check so we don't try and fix something that has already been fixed.

## GitHub Actions Build Request
Can you build a github action that will automatically build the apk and create a github release?

## Version Tag Push Request
Can we push a version tag then please so we get a new version built.

## GitHub Actions Caching Request
Can we make sure there is some good caching in the github actions so everything runs nice and quickly.

## Phase 3 Development Request
While we are waiting to test the latest version. Lets knock out the Phase 3 from the @todo.md. Don't forget to keep the todo list updated. Once you've finished, commit and push to git

## GitHub Actions Fix Note
In the actions file, the Create Release step from 'Build and Release APK' isn't working. This is the message - Run actions/create-release@v1
Error: Resource not accessible by integration

## Prompts File Reminder
Don't forget to also add all prompts to @prompts.md

## Quick Tasks Request
Please have a look through @todo.md and see if there's a few quick tasks to do from either low priority or Anything from Phase 3 or less that has been missed.

## GitHub Actions Error Report
Build APK Action : 3m 54s
[Error message about gyroscopeEventStream not being defined]

## Create New Version Request
We also need to create a new version please

## GitHub Actions Permissions Error
Create release action is giving the following error   shell: /usr/bin/bash -e {0}
  env:
    GITHUB_TOKEN: ***
HTTP 403: Resource not accessible by integration (https://api.github.com/repos/vultuk/avoidance/releases)
Error: Process completed with exit code 1.

## Files Update Check
Is the @prompts.md and @todo.md files up to date?

## Bug Report 4
Below is a list of current bugs. please work though these one at a time.

1. Ships (both blue and orange) can only be moved in one direction.
   - *Blue can only be moved left and right*
   - *Orange can only be move up and down*
2. Shields are not showing on the ships in Medium mode
3. Shield placement is really bad
   - *On the blue ship the right shield is on top of the blue ship*
   - *On the orange ship the bottom shield is on top of the orange ship*
   - *The shields aren't aligned to the middle of the ships*
4. Ultra difficulty is just a blank gray screen. No game appears at all.

## Shield Clarification for Medium Mode
Shields should be shown in Medium mode. However, there should be no game mechanics for them. The shields will not deplete and no power ups will be needed. They are just there for visual clues.

## Shield Damage Clarification
Shields will take damage in Hard AND Ultra mode.

## Bug Report 5
Below is a list of current bugs. please work though these one at a time.

1. In easy mode it's impossible to move the blue ship at all
2. Shield placement is still really bad
   - *On the blue ship the right shield is on top of the blue ship*
   - *On the orange ship the bottom shield is on top of the orange ship*
   - *The shields aren't aligned to the middle of the ships*