https://github.com/ramirez-alberto/wtecc-CICD_PracticeCode

Generate GitHub Personal Access Token

You have a little preparation to do before you can start the lab.
Generate a Personal Access Token

You will fork and clone a repo in this lab using the gh CLI tool. You will also push changes to your cloned repo at the end of this lab. This requires you to authenticate with GitHub using a personal access token. Follow the steps here to generate this token and save it for later use:

    Navigate to GitHub Settings of your account.
    Click Generate new token to create a personal access token.
    Give your token a descriptive name and optionally change the expiration date.
    Select the minimum required scopes needed for this lab: repo, read:org, and workflow.
    Click Generate token.
    Make sure you copy the token and paste it somewhere safe as you will need it in the next step. WARNING: You will not be able to see it again.

    Warning: Keep your tokens safe and protect them like passwords.

If you lose this token at any time, repeat the above steps to regenerate the token.

## Authenticate with GitHub

token: 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

gh auth login

Important: Pull Request

When making a pull request, make sure that your request is merging with your fork because the pull request of a fork will default to come back to this repo, not your fork.

## Create a Workflow

First we need to create a workflow. The first line in this file will define the name of the workflow 
1. Create the directory structure .github/workflows and create a file called workflow.yml
2. Give a name with the name tag as the firsts line name: my name

## Add Event Triggers

Event triggers define which events can cause the workflow to run. You will use the `on:` tag at the same level of indentation of `name:` tag to add the following events:
* Run the workflow on every push to the main branch
* Run the workflow whenever a pull request is created to the main branch.

The event is the child of `on:` tag like the `push` event , in this example you can add the branch with `branches` followed by a list of branches `["main"]` or `-`

## Add a Job
A job is a collection of steps that are run on the events you added in the previous step. The `jobs:` is at the same level of indentation of name:

Name your job `build:` by adding a new line under the `jobs:` section.
You need a runner. you can use the ubuntu-latest runner for this job. You can do this by using the `runs-on:` keyword at the same indentation of the job name.

## Target a dependency

It is important to consistently use the same version of dependencies and operating system for all phases of development including the CI pipeline. For example you need to target python version 3.9, to accomplish that, you can run your workflow in a container inside Github Actions.

Under `runs-on` tag, add `container:`, and the name of your image `python:3.9-slim`

## Add actions

You can add actions with the `steps:` tag as a child og `build:` job name , name the action with a child node `- name:` and at the same level the `uses:` tag

## Install dependencies

You can make another step with another name and the `run:` keyword to run commands like `pip install...` and you can pipe with `|` operator to do inline -> `run: |` and in another line the commands.



Actions>
actions/checkout@v3 - Checkout code