#!/usr/bin/env bash
# medals.sh
###########
# Show the Olympics 2024 medal table.
#
# Data from <https://olympics.com/en/paris-2024/medals>
#
# Dependencies:
# - curl
# - jq
# - htmlq <https://github.com/mgdm/htmlq> (`brew install htmlq`)
#
# meleu - <https://meleu.dev/>

set -Eeuo pipefail
trap 'echo "[ERROR]: ${BASH_SOURCE}:${FUNCNAME}:${LINENO}"' ERR

readonly URL='https://olympics.com/en/paris-2024/medals'

readonly DEPENDENCIES=(curl jq htmlq)

main() {
  # shellcheck disable=2155
  local inputFile="$(mktemp)"
  local jsonFile="${inputFile}.json"
  local amount="${1:-10}"

  checkDependencies

  echo -en "Getting data...\r" >&2
  getMedalPage "$inputFile"
  getJsonData "$inputFile" "$amount" > "$jsonFile"
  renderMedalTable "$jsonFile"

  rm -rf "$inputFile" "$jsonFile"
}

getMedalPage() {
  local file="$1"

  # olympics.com does not accept curl as an user-agent,
  # then we need to send a custom one.
  curl "$URL" \
    --silent \
    --location \
    --user-agent "Mozilla/5.0" \
    --output "$file"
}

getJsonData() {
  local file="$1"
  local max="${2:-10}"
  local jqFilter

  jqFilter="
    .props.pageProps.initialMedals.medalStandings.medalsTable[:${max}]
      | [ .[]
          | {
            description,
            medalsNumber: [.medalsNumber[] | select(.type == \"Total\")]
          }
        ]
      | [.[] | {description, medalsNumber: .medalsNumber[0]}]
  "

  htmlq --text 'script#__NEXT_DATA__' --filename "$file" \
    | jq "${jqFilter}"
}

renderMedalTable() {
  local jsonFile="$1"
  local medalTableData
  local jqFilter
  local line
  local rank=0
  local gold silver bronze total country

  jqFilter='.[] |
    "\(
      .medalsNumber.gold
    ):\(
      .medalsNumber.silver
    ):\(
      .medalsNumber.bronze
    ):\(
      .medalsNumber.total
    ):\(
      .description
    )"
  '

  medalTableData="$(jq --raw-output "$jqFilter" "$jsonFile")"

  echo " rank |  🥇 |  🥈 |  🥉 | total | Country"
  echo "------|-----|-----|-----|-------|---------"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    IFS=':' read -r gold silver bronze total country <<< "$line"
    printf " %4s | %3s | %3s | %3s | %5s | %s\n" \
      "$((++rank))" "$gold" "$silver" "$bronze" "$total" "$country"
  done <<< "$medalTableData"

  echo -e "\nSource: $URL"
}

checkDependencies() {
  local bin
  local failure=false

  for bin in "${DEPENDENCIES[@]}"; do
    command -v "$bin" > /dev/null && continue
    echo "[ERROR]: '$bin' is not in your PATH"
    failure=true
  done

  [[ "$failure" == 'false' ]]
}

main "$@"
