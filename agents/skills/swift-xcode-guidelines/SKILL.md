---
name: swift-xcode-guidelines
description: Swift and Xcode project conventions. Use when working with Swift code or Xcode projects. Triggers on .swift files, Xcode projects, or project.yml (XcodeGen).
---

# Swift/Xcode Guidelines

## XcodeGen Projects

If `project.yml` exists: treat `.xcodeproj` as generated.
- Edit `project.yml`
- Run `xcodegen`
- Never hand-edit `project.pbxproj`
