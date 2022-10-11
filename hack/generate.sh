#!/bin/bash
#shellcheck disable=SC2129,SC2164
#set -euo pipefail

MANIFESTS="assets"
TOP=$(git rev-parse --show-toplevel)
TMPDIR="${TOP}/tmp/repos"

# Make sure to use project tooling
PATH="${TOP}/tmp/bin:${PATH}"


download_mixin() {
	local mixin="$1"
	local repo="$2"
	local subdir="$3"
	local customfile="$4"

	git clone --depth 1 "$repo" "${TMPDIR}/$mixin"
	mkdir -p "${TOP}/${MANIFESTS}/${mixin}/dashboards"
	(
		cd "${TMPDIR}/${mixin}/${subdir}"
		if [ -f "jsonnetfile.json" ]; then
			jb install
		fi

		if [ -f "${TOP}/custom/$customfile" ]; then
			cp ${TOP}/custom/$customfile ./
			jsonnet -J vendor -S -e 'std.manifestYamlDoc((import "'$customfile'").prometheusAlerts)' | gojsontoyaml > "${TOP}/${MANIFESTS}/${mixin}/alerts.yaml" || :
			jsonnet -J vendor -S -e 'std.manifestYamlDoc((import "'$customfile'").prometheusRules)' | gojsontoyaml > "${TOP}/${MANIFESTS}/${mixin}/rules.yaml" || :
			jsonnet -J vendor -m "${TOP}/${MANIFESTS}/${mixin}/dashboards" -e '(import "'$customfile'").grafanaDashboards' || :
		else
			jsonnet -J vendor -S -e 'std.manifestYamlDoc((import "mixin.libsonnet").prometheusAlerts)' | gojsontoyaml > "${TOP}/${MANIFESTS}/${mixin}/alerts.yaml" || :
			jsonnet -J vendor -S -e 'std.manifestYamlDoc((import "mixin.libsonnet").prometheusRules)' | gojsontoyaml > "${TOP}/${MANIFESTS}/${mixin}/rules.yaml" || :
			jsonnet -J vendor -m "${TOP}/${MANIFESTS}/${mixin}/dashboards" -e '(import "mixin.libsonnet").grafanaDashboards' || :
		fi
	)
}

parse_rules() {
	local source="$1"
	local type="$2"
	for group in $(echo "$source" | jq -cr '.groups[].name'); do
		echo -e "### ${group}\n"
		for rule in $(echo "$source" | jq -cr ".groups[] | select(.name == \"${group}\") | .rules[] | @base64"); do
			var=$(echo "$rule" | base64 --decode | gojsontoyaml);
			name=$(echo -e "$var" | grep "$type" | awk -F ': ' '{print $2}')
			echo -e "##### ${name}\n"
			echo -e '{{< code lang="yaml" >}}'
			echo -e "$var"
			echo -e '{{< /code >}}\n '
		done
	done
}

panel() {
	echo -e "{{< panel style=\"$1\" >}}"
	echo -e "$2"
	echo -e "{{< /panel >}}\n"
}

mixin_header() {
	local name="$1"
	local repo="$2"
	local url="$3"
	local description="$4"

	cat << EOF
---
title: $name
---

## Overview

$description

EOF
panel "danger" "Jsonnet source code is available at [${repo#*//}]($url)"
}


cd "${TOP}" || exit 1
# remove generated assets and temporary directory
rm -rf "$MANIFESTS" "$TMPDIR"
# remove generated site content
find content/ ! -name '_index.md' -type f -exec rm -rf {} +

mkdir -p "${TMPDIR}"

# Generate mixins 
CONFIG="mixins.json"

for mixin in $(cat "$CONFIG" | jq -r '.mixins[].name'); do
	repo="$(cat "$CONFIG" | jq -r ".mixins[] | select(.name == \"$mixin\") | .source")"
	subdir="$(cat "$CONFIG" | jq -r ".mixins[] | select(.name == \"$mixin\") | .subdir")"
	text="$(cat "$CONFIG" | jq -r ".mixins[] | select(.name == \"$mixin\") | .description")"
	if [ "$text" == "null" ]; then text=""; fi
	customfile="$(cat "$CONFIG" | jq -r ".mixins[] | select(.name == \"$mixin\") | .customfile")"
	if [ "$customfile" == "null" ]; then customfile=""; fi

	set +u
	download_mixin "$mixin" "$repo" "$subdir" "$customfile"
	#set -u

	mkdir -p "content/${mixin}"
	file="content/${mixin}/_index.md"
	# Create header
	if [ -n "$subdir" ]; then
		location="$repo/tree/master/$subdir"
	else
		location="$repo"
	fi
	mixin_header "$mixin" "$repo" "$location" "$text" > "$file"

	dir="$TOP/$MANIFESTS/$mixin"
	# Alerts
	if [ -s "$dir/alerts.yaml" ] && [ "$(stat -c%s "$dir/alerts.yaml")" -gt 20 ]; then
		echo -e "## Alerts\n" >> "$file"
		panel "warning" "Complete list of pregenerated alerts is available [here](https://github.com/observeproject/sites/blob/main/$MANIFESTS/$mixin/alerts.yaml)." >> "$file"
		parse_rules "$(gojsontoyaml -yamltojson < "$dir/alerts.yaml")" "alert" >> "$file"
	fi

	# Recording Rules
	if [ -s "$dir/rules.yaml" ] && [ "$(stat -c%s "$dir/rules.yaml")" -gt 20 ]; then
		echo -e "## Recording rules\n" >> "$file"
		panel "warning" "Complete list of pregenerated recording rules is available [here](https://github.com/observeproject/sites/blob/main/$MANIFESTS/$mixin/rules.yaml)." >> "$file"
		parse_rules "$(gojsontoyaml -yamltojson < "$dir/rules.yaml")" "record" >> "$file"
	fi

	# Dashboards
	if [ "$(ls -A "$dir/dashboards")" ]; then
		echo -e "## Dashboards\nFollowing dashboards are generated from mixins and hosted on github:\n\n" >> "$file"
		for dashboard in "$dir/dashboards"/*.json; do
			d="$(basename "$dashboard")"
			echo "- [${d%.*}](https://github.com/observeproject/sites/blob/main/$MANIFESTS/$mixin/dashboards/$d)" >> "$file"
		done
	fi
done

cd "${TOP}" || exit 1
cp -f "${CONFIG}" "static/"
