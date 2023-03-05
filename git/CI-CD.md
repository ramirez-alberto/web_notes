
# Continuous Delivery

You can trigger the CD pipeline via a webhook from github

# Tools

## Tekton 
[Examples]("https://github.com/ibm-developer-skills-network/wtecc-CICD_PracticeCode.git")

### Structuring Tekton pipeline project

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
2. Create a pipeline, reference the previous task and apply to kubernetes `kubectl apply -f file.yaml`. You can check the pipeline status in Tekton `tkn pipeline ls`
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

The next examples are avaliable:

* [With parameters](#task-yaml-with-parameters)

* [Checkout pipeline](#checkout-pipeline)
* 
### Tekton Triggers

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

   * The first thing you want to do is give the TriggerTemplate the same name that is referenced in the EventListener resourcetemplates
   * Add a `serviceAccountName:` with a value of pipeline.
   * Add a `pipelineRef:` that refers to the cd-pipeline created in the last lab.
   * Add a parameter named repo-url with a value referencing the TriggerTemplate repository parameter above.
   * Add a second parameter named branch with a value referencing the TriggerTemplaterepository parameter above. Apply to kubernetes `kubectl apply -f triggertemplate.yaml`
```YAML
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
```

4. Start a PipelineRun on a port with `kubectl port-forward service/el-cd-listener  8090:8080`. 
   Run port-forward to send the service to your localhost. You can use a curl command to test your EventListener:
```bash
    curl -X POST http://localhost:8090 \
  -H 'Content-Type: application/json' \
  -d '{"ref":"main","repository":{"url":"https://github.com/ibm-developer-skills-network/wtecc-CICD_PracticeCode"}}'
```

You can check the pipeline and the pipeline logs with 

```
tkn pipelinerun ls
tkn pipelinerun logs --last
```

Now that you know your triggers are working, you can expose the event listener service with an ingress and call it from a webhook in GitHub and have it run on changes to your GitHub repository.



### Task yaml with parameters:
```YAML
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

--- pipeline.yaml -------------------

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

--- Terminal ---------------------------

tkn pipeline start hello-pipeline \
    --showlog  \
    -p message="Hello Tekton!"
```

### Checkout Pipeline
```YAML
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
kind: Task
metadata:
  name: nose
spec:
  workspaces:
    - name: source
  params:
    - name: args
      description: Arguments to pass to nose
      type: string
      default: "-v"
  steps:
    - name: nosetests
      image: python:3.9-slim
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/bash
        set -e
        python -m pip install --upgrade pip wheel
        pip install -r requirements.txt
        nosetests $(params.options)

--- pipeline.yaml ---------------------------------

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

--- Terminal --------------------------------

tkn pipeline start cd-pipeline \
    --showlog \
    -p repo-url="https://github.com/ibm-developer-skills-network/wtecc-CICD_PracticeCode.git" \
    -p branch="main"

```

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

### Tekton CD Catalog
1. Use the Tekton CD Catalog to install the git-clone task

```bash
tkn hub install task git-clone
```
2. Create a workspace. A workspace is a disk volume that can be shared across tasks. The way to bind to volumes in Kubernetes is with a PersistentVolumeClaim.. Apply to kubernetes `kubectl apply -f pvc.yaml`
3. Add a workspace to the pipeline. Add a `workspaces:` definition as the first line under the `spec:` but before the `params:` and name it. Then you will add the workspace to the task and change the task to reference git-clone instead of your checkout task. Apply kubectl apply -f pipeline.yaml
``` YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  workspaces:
    - name: pipeline-workspace
  params:
    - name: repo-url
    - name: branch
      default: "master"
  tasks:
    - name: clone
      workspaces:
        - name: output
          workspace: pipeline-workspace
      taskRef:
        name: git-clone
      params:
      - name: url
        value: $(params.repo-url)
      - name: revision
        value: $(params.branch)
```

Use the Tekton CLI (`tkn`) to create a `PipelineRun` to run the pipeline

```bash
 tkn pipeline start cd-pipeline \
    -p repo-url="https://github.com/ibm-developer-skills-network/wtecc-CICD_PracticeCode.git" \
    -p branch="main" \
    -w name=pipeline-workspace,claimName=pipelinerun-pvc \
    --showlog
```

You should get into the habit of always checking the Tekton Catalog at Tekton Hub before writing any task. Remember: **“A line of code you did not write is a line of code that you do not have to maintain!”**


### Build a image and push it to registry

***This example use buildah task from Tekton Hub***

You can check available task in the ClusterTasks with `tkn clustertask ls` .
A `ClusterTask` is installed cluster-wide by an administrator and anyone can use it in their pipelines without having to install it themselves.

To reference a ClusterTask in the pipeline.yaml, under the task name add a `kind:` tag with value ClusterTask so that Tekton knows to look for a ClusterTask and not a regular Task.

tkn pipeline start cd-pipeline \
    -p repo-url="https://github.com/ibm-developer-skills-network/wtecc-CICD_PracticeCode.git" \
    -p branch=main \
    -p build-image=image-registry.openshift-image-registry.svc:5000/$SN_ICR_NAMESPACE/tekton-lab:latest \
    -w name=pipeline-workspace,claimName=pipelinerun-pvc \
    --showlog

### Deploy to Openshift
Use the kubectl command to check that your deployment is in a running state.
`kubectl get all -l app=hitcounter`