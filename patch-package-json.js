#!/usr/bin/env node

// based on https://github.com/storybookjs/storybook/blob/13b3032301f24375e1204666a19cad693552064e/scripts/utils/package-json.ts#L5

import pkg from 'fs-extra';
const { readJSON, writeJSON } = pkg;
const packageJsonPath = './package.json';

export async function updateForLint() {
  const packageJson = await readJSON(packageJsonPath);

  packageJson.scripts = {
    ...packageJson.scripts,
    ...({
      "lint": "eslint .",
      "lint:fix": "npm run lint -- --fix",
    }),
  };
  await writeJSON(packageJsonPath, packageJson, { spaces: 2 });
}

export async function updateForLintStaged() {
  const packageJson = await readJSON(packageJsonPath);

  packageJson["lint-staged"] = {
    "*.{js,jsx,ts,tsx,svelte}": "npm run lint:fix",
  };
  await writeJSON(packageJsonPath, packageJson, { spaces: 2 });
}

export async function updateForHusky() {
  const packageJson = await readJSON(packageJsonPath);

  packageJson.scripts = {
    ...packageJson.scripts,
    ...({
      prepare: "husky install",
    }),
  };
  await writeJSON(packageJsonPath, packageJson, { spaces: 2 });
}

async function main() {
  const arg = process.argv[2];
  switch (arg) {
    case 'lint':
      await updateForLint()
      break;
    case 'lint-staged':
      await updateForLintStaged()
      break;
    case 'husky':
      await updateForHusky()
      break;
    default:
      console.error('No arg is provided. Exiting.')
      break;
  }
}

main();
