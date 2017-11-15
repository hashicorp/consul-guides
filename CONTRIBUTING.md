# Consul Guides Contribution

Please ensure contributions are categorized properly, following existing conventions, with a simple description in the categorized folder (e.g. consul-guides/service-discovery/single-dc-failover/README.md).

Every guide should include a well documented README using the [template](#template) below.

If there are additional notes, diagrams, or instructions that make sense to be included, please provide them in a separate markdown page adjacent to the README. Assets used in the guide such as images should be placed in an `assets` folder in the same directory.

# Template

----

# Guide Name
Summary of pain point/challenge/business case and goal of the guide in 2 paragraphs

## Reference Material
Any relevant reference material that will help the user better understand the use case being solved for

## Estimated Time to Complete
A rough estimate of time it would take a beginner to read the guide and complete the steps. The assumption is that they completed the prerequisites.

## Challenge
Paragraph describing the challenge

## Solution
Paragraph describing the proposed solution

## Prerequisites
Any prerequisite guides or material that should be completed before starting

## Steps
Summary of steps involved to solve the challenge, perhaps embedded screencast walkthrough. Not all steps will have UI, API, and CLI components.

### Step n: <Step Title>
Summary of what will be completed in this step

#### UI
Link to docs for this command if available
##### Request
UI request screenshot(s)

##### Response
UI response screenshot(s)

#### cURL
Link to docs for this command if available

##### Request
```sh
$ <curl request command>
```

Link to specific cURL request command in accompanying guide script

##### Response
```
<curl request response output>
```

#### CLI
Link to docs for this command if available

##### Request
```sh
$ vault read secret/path
```

Link to specific CLI request command in accompanying guide script

##### Response
```
CLI request response output
```

#### Validation
Summary of inspec test(s) used to validate the step was completed successfully

##### Request
```sh
$ <validation command>
```

Link to specific validation command in accompanying guide script

##### Response
```
validation output
```

#### Reference Content
- Any reference content that might be valuable

## Next Steps
- Link to next guide that should be completed
