#!/usr/bin/env bash

set -e

script_d="$(dirname "$0")"
script_abs_d="$(realpath "${script_d}")"

patch_pkg_json="${script_abs_d}/patch-package-json.js"

patch_d="${script_abs_d}/patches"

patch_husky="${patch_d}/husky.patch"
patch_makefile="${patch_d}/makefile.patch"
patch_eslint="${patch_d}/eslintrc.cjs.patch"
patch_prettier="${patch_d}/prettierrc.patch"
patch_storybook_button="${patch_d}/storybook.button.patch"
patch_storybook_preview="${patch_d}/storybook.preview.patch"

shopt -s globstar # https://unix.stackexchange.com/a/49917/396504

new_project_name="${1:-my-sveltekit-polished}"
config_file="${2:-"${script_abs_d}/cswc.mjs"}"

# for ./patch-package-json.js to function properly
pushd "${script_abs_d}"; npm i; popd

git_add_and_diff ()
{
  git add .
  git reset package-lock.json
  git --no-pager diff --cached
  git add package-lock.json
}


## beginning of testing only
echo deleting "${new_project_name}" while tests
rm -rf "${new_project_name}"
## end of testing only

yes | npm create svelte-with-config "${config_file}" "${new_project_name}"

# enter the generated project
pushd "${new_project_name}"

##### initialize with git
git init
git add .
git status

##### switch tabs to 2 spaces

sed -i 's/\t/  /g' .prettierrc .*.cjs **/*.js **/*.ts **/*.svelte **/*.json **/*.html
git --no-pager diff
git add .
git commit -m 'Initial commit'

npm i
git add package-lock.json
git commit -m 'Run `npm i` initially'


##### setup eslint and prettier

git apply "${patch_prettier}"

npm uninstall eslint-plugin-svelte3
npm install --save-dev eslint-plugin-svelte eslint-plugin-prettier

git_add_and_diff
git commit -m 'Install eslint-plugin-prettier'

git apply "${patch_eslint}"

"${patch_pkg_json}" lint

git_add_and_diff
git commit -m 'Patch .prettierrc and .eslintrc.cjs package.json

to rely on eslint to fix prettier formatting as well'

npm run lint:fix
git add .
git --no-pager diff --cached
git commit -m 'npm run lint:fix'


##### setup lint-stage and husky

npm install --save-dev lint-staged
git add package.json

"${patch_pkg_json}" lint-staged
git apply "${patch_husky}"
"${patch_pkg_json}" husky

npm install husky --save-dev

git_add_and_diff
npm run prepare # trigger husky git hook installation
git commit -m "Setup husky and lint-staged"

##### add tailwindcss

npx svelte-add@latest tailwindcss
npm i
git_add_and_diff
git commit -m "Add tailwindcss"

##### setup Storybook 7

yes | npx storybook@next init

git_add_and_diff
git commit -m "Add storybook"

git apply "${patch_storybook_preview}"
git apply "${patch_storybook_button}"

git_add_and_diff
git commit -m "Patch for storybook"
# when running storybook for the first time it might take time to function properly
# or refresh once for the pages that have an error about '$$' blahblah


##### add Makefile

git apply "${patch_makefile}"
git_add_and_diff
git commit -m "Add Makefile"


##### finale
popd

echo "you may \`cd ${new_project_name}\` to start coding"
