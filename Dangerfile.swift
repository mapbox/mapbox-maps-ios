// swiftlint:disable explicit_acl explicit_top_level_acl
import Danger
import Foundation

let danger = Danger()

// MARK: Checks for if there are labels on the Pull Request
let labelsCount = danger.github.issue.labels.count

if labelsCount == 0 {
    fail("No labels on PR, please add appropriate label")
}

// MARK: Linting
SwiftLint.lint(inline: true)
