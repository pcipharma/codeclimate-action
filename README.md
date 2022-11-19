# codeclimate-action

[![Test Coverage](https://api.codeclimate.com/v1/badges/-codeclimate-id-/test_coverage)](https://codeclimate.com/github/pcipharma/codeclimate-action/test_coverage)
[![Build Status](https://github.com/pcipharma/codeclimate-action/workflows/PR%20Checks/badge.svg)][![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A GitHub action that publishes your code coverage to [Code Climate](http://codeclimate.com/).

## Development

Since the repository implements a GitHub Action, the content of the repository must be in a state to be pulled and executed directly, without requiring building or installing packages.
To accomplish this, we use `@vercel/ncc` to package all code and dependencies into the `dist/index.js` file.
Therefore, we need to commit the build output to the repository to enable easy consumption in other workflows.

### Commit

When building, ensure that the following is done before committing the code.

```bash
npm run format
npm run build
npm run package
npm run test
```

See the [CONTRIBUTING.md](./CONTRIBUTING.md) file for information on commit meessage conventions.

### Release

In order to make a new release, create a tag using the `create-release.sh` script.
The tag should follow the format `rcMAJOR.MINOR.PATCH`, for example `rc3.2.1`.

```bash
./scripts/create-release.sh rc3.2.1
```

This will kick off GitHub Action workflows to run the `npm semantic-release` process.
The release process will look at all commits since the last tag and determine the next version number as appropriate based on the identified changes.
This is why it is important to follow the commit message format defined in [CONTRIBUTING.md](./CONTRIBUTING.md).

For consumers that want to have the latest plugin, we provide the `vMAJOR` tag (currently `v3`).
Make sure the top-level `v3` (or the current major number) tag shifts to point to the latest release tag.
This should be done after the GitHub Actions workflow completes.

> TODO: We desire to automate this process of shifting the `vMAJOR` tag to support automations which use the plugin.

```bash
git checkout v3.2.1
./scripts/create-release.sh v3
```

## Usage

This action requires that you set the [`CC_TEST_REPORTER_ID`](https://docs.codeclimate.com/docs/configuring-test-coverage) environment variable.
You can find it under Repo Settings in your Code Climate project.

### Inputs


|Input|Default|Description
|-----|-------|-----------
|`coverageCommand`||The actual command that should be executed to run your tests and capture coverage.
|`workingDirectory`||Specify a custom working directory where the coverage command should be executed.
|`debug`|`false`|Enable Code Coverage debug output when set to `true`.
|`coverageLocations`||Locations to find code coverage as a multiline string.<br>Each line should be of the form `<location>:<type>`.<br>`type` can be any one of `clover`, `cobertura`, `coverage.py`, `excoveralls`, `gcov`, `gocov`, `jacoco`, `lcov`, `lcov-json`, `simplecov`, `xccov`. See examples below.
|`prefix`|`undefined`|See [`--prefix`](https://docs.codeclimate.com/docs/configuring-test-coverage)
|`verifyDownload`|`true`|Verifies the downloaded Code Climate reporter binary\'s checksum and GPG signature. See [Verifying binaries](https://github.com/codeclimate/test-reporter#verifying-binaries)


#### Example

```yaml
steps:
  - name: Test & publish code coverage
    uses: pcipharma/codeclimate-action@v3
    env:
      CC_TEST_REPORTER_ID: <code_climate_reporter_id>
    with:
      coverageCommand: npm run coverage
      debug: true
```

#### Example with only upload

When you've already generated the coverage report in a previous step and wish to just upload the coverage data to Code Climate, you can leave out the `coverageCommand` option.

```yaml
steps:
  - name: Test & publish code coverage
    uses: pcipharma/codeclimate-action@v3
    env:
      CC_TEST_REPORTER_ID: <code_climate_reporter_id>
```

#### Example with wildcard (glob) pattern

This action supports basic glob patterns to search for files matching given patterns. It uses [`@actions/glob`](https://github.com/actions/toolkit/tree/master/packages/glob#basic) to expand the glob patterns.

```yaml
steps:
  - name: Test & publish code coverage
    uses: pcipharma/codeclimate-action@v3
    env:
      CC_TEST_REPORTER_ID: <code_climate_reporter_id>
    with:
      coverageCommand: yarn run coverage
      coverageLocations: |
        ${{github.workspace}}/*.lcov:lcov
```

#### Example with Jacoco

```yaml
steps:
  - name: Test & publish code coverage
    uses: pcipharma/codeclimate-action@v3
    env:
      # Set CC_TEST_REPORTER_ID as secret of your repo
      CC_TEST_REPORTER_ID: ${{secrets.CODECLIMATE_KEY}}
      JACOCO_SOURCE_PATH: "${{github.workspace}}/src/main/java"
    with:
      # The report file must be there, otherwise Code Climate won't find it
      coverageCommand: mvn test
      coverageLocations: ${{github.workspace}}/target/site/jacoco/jacoco.xml:jacoco
```

#### Example of multiple test coverages for monorepo with Jest

Let's say you have a monorepo with two folders —`client` and `server`, both with their own coverage folders and a `yarn coverage` script which runs Jest within both folders.

```json
"scripts": {
  "coverage": "yarn client coverage && yarn server coverage"
}
```

First be sure that paths in your `coverage/lcov.info` are correct; they should be either absolute or relative to the **root** of the monorepo. Open `lcov.info` and search for any path. For example —

```lcov
SF:src/server.ts
```

If you find a *relative* path like this (happens for Jest 25+), it's incorrect as it is relative to the sub-package. This can be fixed by configuring Jest to set the root of your monorepo —

```javascript
// server/jest.config.js
module.exports = {
  ...
  coverageReporters: [['lcov', { projectRoot: '..' }]]
  ...
};
```

```yaml
steps:
  - name: Test & publish code coverage
    uses: pcipharma/codeclimate-action@v3
    env:
      CC_TEST_REPORTER_ID: ${{secrets.CC_TEST_REPORTER_ID}}
    with:
      coverageCommand: yarn run coverage
      coverageLocations: |
        ${{github.workspace}}/client/coverage/lcov.info:lcov
        ${{github.workspace}}/server/coverage/lcov.info:lcov
```

## Example projects

1. [MartinNuc/coverage-ga-test](https://github.com/MartinNuc/coverage-ga-test/blob/master/.github/workflows/ci.yaml)

## Acknowledgements

Based on code forked from https://github.com/paambaati/codeclimate-action.git
