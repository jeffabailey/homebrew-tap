# Jeffabailey Tap

## Formulae

| Formula | Description | Platforms |
| --- | --- | --- |
| `aws-emulator` | [AWS Emulator](https://github.com/aws/aws-emulator), a local emulator of the AWS APIs. Linux installs the upstream package. macOS installs a binary that this tap builds from the upstream tag with one patch; see [`macos/`](macos/). | Linux (x86_64, arm64), macOS (arm64) |

## How do I install these formulae?

`brew install jeffabailey/tap/<formula>`

Or `brew tap jeffabailey/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "jeffabailey/tap"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
