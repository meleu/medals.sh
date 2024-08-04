# medals.sh

Check the Olympics 2024 medal table from the comfort of your terminal.

Data comes from <https://olympics.com/en/paris-2024/medals>.

## Usage

```bash
# get the top 10 (default amount)
medals

# get the top 15
medals 15
```

Examples:

![Made with VHS](https://vhs.charm.sh/vhs-4m8XRluYAkwcrJfu4Q2lQf.gif)

## Dependencies

- bash
- [curl](https://curl.se/): to get the data
- [htmlq](https://github.com/mgdm/htmlq): to parse contents from an HTML file
- [jq](https://jqlang.github.io/jq): to parse JSON data

Assuming you have [Homebrew](https://brew.sh) installed,
you can install the dependencies with:

```bash
brew install curl
brew install htmlq
brew install jq
```

## Installation

Just copy [medals.sh](./medals.sh) and put it anywhere in your PATH.

Here's a suggestion:

```bash
mkdir -p ~/.local/bin
curl 'https://raw.githubusercontent.com/meleu/medals.sh/main/medals.sh' > ~/.local/bin/medals
chmod a+x ~/.local/bin/medals
```
