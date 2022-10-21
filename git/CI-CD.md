
# Continuous Delivery

## Tools

### Tekton

#### Structuring Tekton pipeline project

How to author Tekton pipelines and tasks so that they are easy to use and parameterize.
You can have multiple definitions in a single yaml file by separating them with three dashes `---` on a single line.
1. Create a task `task.yaml` and register to kubernetes `kubectl apply -f tasks.yaml`
   You can check the task in Tekton with `tkn task ls` 
```YAML
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: hello-world
spec:
  steps:
    - name: echo
      image: alpine:3
      command: [/bin/echo]
      args: ["Hello World"]
```
1. Create a pipeline, reference the previous task and apply to kubernetes `kubectl apply -f file.yaml`. You can check the pipeline status in Tekton `tkn pipeline ls`
```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: hello-pipeline
spec:
  tasks:
    - name: hello
      taskRef:
        name: hello-world
```
3. Run the pipeline using Tekton CLI `tkn pipeline start --showlog hello-pipeline`

#### Tekton Triggers

1. Create an EventListener that references a TriggerBinding and a TriggerTemplate
   * In the Eventlistener yaml, add a Service Account `serviceAccountName:` in the `spec:` section
   * Define the `triggers:` under `spec:` This is where you will define the bindings and template.
   * Add a bindings: section under the triggers: section with a `ref:` to TriggerBinding name. Since there can be mutiple triggers, make sure you define - bindings as a list using the dash - prefix. Also since there can be multiple bindings, make sure you defne the - ref: with a dash - prefix as well.
   * Add a template: section at the same level as bindings with a ref: to TriggerTemplate and apply to `kubernetes kubectl apply -f eventlistener.yaml`.

You can check the event trigger with `tkn eventlistener ls`
```YAML
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: cd-listener
spec:
  serviceAccountName: pipeline
  triggers:
    - bindings:
      - ref: cd-binding
      template:
        ref: cd-template
```

2. Create a TriggerBinding. A TriggerBinding is a way to bind the incoming data from the event to pass on to the pipeline. Apply to kubernetes `kubectl apply -f triggerbinding.yaml`

```YAML
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: cd-binding
spec:
  params:
    - name: repository
      value: $(body.repository.url)
    - name: branch
      value: $(body.ref)
```

3. Create a TriggerTemplate. The TriggerTemplate takes the parameters passed in from the TriggerBinding and creates a PipelineRun to start the pipeline

* The first thing you want to do is give the TriggerTemplate the same name that is referenced in the EventListener
resourcetemplates

    Add a serviceAccountName: with a value of pipeline.

    Add a pipelineRef: that refers to the cd-pipeline created in the last lab.

    Add a parameter named repo-url with a value referencing the TriggerTemplate repository parameter above.

    Add a second parameter named branch with a value referencing the TriggerTemplaterepository parameter above. kubectl apply -f triggertemplate.yaml

apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: cd-template
spec:
  params:
    - name: repository
      description: The git repo
      default: " "
    - name: branch
      description: the branch for the git repo
      default: master
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: cd-pipeline-run-
      spec:
        serviceAccountName: pipeline
        pipelineRef:
          name: cd-pipeline
        params:
          - name: repo-url
            value: $(tt.params.repository)
          - name: branch
            value: $(tt.params.branch)

    Start a PipelineRun on a port > kubectl port-forward service/el-cd-listener  8090:8080
        Run port-forward to send the service to your localhost and use a curl command to test your EventListener

    Trigger the e vent:
    curl -X POST http://localhost:8090 \
  -H 'Content-Type: application/json' \
  -d '{"ref":"main","repository":{"url":"https://github.com/ibm-developer-skills-network/wtecc-CICD_PracticeCode"}}'

  tkn pipelinerun ls
  tkn pipelinerun logs --last

  Now that you know your triggers are working, you can expose the event listener service with an ingress and call it from a webhook in GitHub and have it run on changes to your GitHub repository.

With parameters:
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: echo
spec:
  params:
    - name: message
      type: string
      description: The message to echo
  steps:
    - name: echo-message
      image: alpine:3
      command: [/bin/echo]
      args: ["$(params.message)"]

apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: hello-pipeline
spec:
  params:
    - name: message
  tasks:
    - name: hello
      taskRef:
        name: echo
      params:
        - name: message
          value: "$(params.message)"

tkn pipeline start hello-pipeline \
    --showlog  \
    -p message="Hello Tekton!"

Checkout Pipeline

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: echo
spec:
  params:
    - name: message
      type: string
      description: The message to echo
  steps:
    - name: echo-message
      image: alpine:3
      command: [/bin/echo]
      args: ["$(params.message)"]
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: checkout
spec:
  params:
    - name: repo-url
      description: The URL of the git repo to clone
      type: string
    - name: branch
      description: The branch to clone
      type: string
  steps:
    - name: checkout
      image: bitnami/git:latest
      command: [git]
      args: ["clone", "--branch", "$(params.branch)", "$(params.repo-url)"]


---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  params:
    - name: repo-url
    - name: branch
      default: "master"
  tasks:
    - name: clone
      taskRef:
        name: checkout
      params:
      - name: repo-url
        value: "$(params.repo-url)"
      - name: branch
        value: "$(params.branch)"

tkn pipeline start cd-pipeline \
    --showlog \
    -p repo-url="https://github.com/ibm-developer-skills-network/wtecc-CICD_PracticeCode.git" \
    -p branch="main"


PIPELINE FOR FUTURE
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  params:
    - name: repo-url
    - name: branch
      default: "master"
  tasks:
    - name: clone
      taskRef:
        name: checkout
      params:
      - name: repo-url
        value: "$(params.repo-url)"
      - name: branch
        value: "$(params.branch)"

    - name: lint
      taskRef:
        name: echo
      params:
      - name: message
        value: "Calling Flake8 linter..."
      runAfter:
        - clone

    - name: tests
      taskRef:
        name: echo
      params:
      - name: message
        value: "Running unit tests with PyUnit..."
      runAfter:
        - lint

    - name: build
      taskRef:
        name: echo
      params:
      - name: message
        value: "Building image for $(params.repo-url) ..."
      runAfter:
        - tests

    - name: deploy
      taskRef:
        name: echo
      params:
      - name: message
        value: "Deploying $(params.branch) branch of $(params.repo-url) ..."
      runAfter:
        - build