#!/usr/bin/env bash

script_d="$(dirname "$0")"
script_abs_d="$(realpath "${script_d}")"
patch_d="${script_abs_d}/patches"
patch_husky="${patch_d}/husky.patch"
patch_eslint="${patch_d}/eslintrc.cjs.patch"
patch_prettier="${patch_d}/prettierrc.patch"
patch_package_json_lint="${patch_d}/package.json.lint.patch"
patch_package_json_husky="${patch_d}/package.json.husky.patch"
patch_package_json_lint_staged="${patch_d}/package.json.lint-staged.patch"

shopt -s globstar # https://unix.stackexchange.com/a/49917/396504

name="${1:-my-sveltekit-polished}"

git_add_and_diff ()
{
  git add .
  git reset package-lock.json
  git --no-pager diff --cached
  git add package-lock.json
}


## beginning of testing only
echo deleting "${name}" while tests
rm -rf "${name}"
## end of testing only

yes | npm create svelte-with-config cswc.mjs "${name}"

# enter the generated project
pushd "${name}"

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
git add package-lock.json

git apply "${patch_eslint}"
git apply "${patch_package_json_lint}"

git_add_and_diff
git commit -m 'patch .prettierrc and .eslintrc.cjs package.json

to rely on eslint to fix prettier formatting as well'

npm run lint:fix
git add .
git --no-pager diff --cached
git commit -m 'npm run lint:fix'


##### setup lint-stage and husky

npm install --save-dev lint-staged
git apply "${patch_package_json_lint_staged}"

git apply "${patch_husky}"
git apply "${patch_package_json_husky}"

npm install husky --save-dev

git_add_and_diff
npm run prepare # trigger husky git hook installation
git commit -m "setup husky and lint-staged"

##### add tailwindcss

npx svelte-add@latest tailwindcss
npm i
git_add_and_diff
git commit -m "add tailwindcss"

##### setup Storybook 7

yes | npx storybook@next init

git_add_and_diff
git commit -m "add storybook"
