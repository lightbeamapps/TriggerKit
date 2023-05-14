# How you can Contribute

## Answer issues and contribute to discussions

Answering [issues](https://github.com/lightbeamapps/TriggerKit/issues), participating in [discussions](https://github.com/lightbeamapps/TriggerKit/discussions) is a great way to help, get familiar with the library, and shape its direction.

## Contribute to the TriggerKit codebase

### Clone the `main` branch on your machine.

- Open the folder in Xcode (or your preferred editor with Swift support)

### Run tests

You can run tests using the Swift CLI by running `swift test` in the root of the project.

You can also execute tests in Xcode by switching to the Test navigator and executing one or more tests.

### Please respect the existing coding style

- Get familiar with the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Whitespace-only lines are not trimmed.
- We use SwiftLint to ensure a consistent look and feel of the library code. Your changes should contain no SwiftLint errors or warnings. Please run and check SwiftLint on any code contributions before submitting e.g. `swiftlint lint --fix --format`.
- Avoid bringing in new libraries or dependencies without good justification. Any PR that brings in a new library needs to make the case for why it is necessary.

### Please provide documentation for your changes

All methods and types that the library makes public, should have a meaningful description and information on how to use.

It is recommended to include unit tests covering your changes.

Optionally, you may consider extending one of the examples in order to showcase the new functionality.

### Talk to the maintainer 🤙

We'd love it if you'd talk to us over on the Fediverse! The current maintainer and admin for TriggerKit is:

- [David Gary Wood](https://social.davidgarywood.com/@davidgarywood)

### Open a pull request with your changes (targeting the `main` branch)!
