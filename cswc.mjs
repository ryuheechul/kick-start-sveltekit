// based on https://github.com/sveltejs/kit/tree/master/packages/create-svelte#api

export default {
  name: 'my-new-app-via-config',
  template: 'skeleton', // or 'default' or 'skeletonlib'
  types: 'typescript', // or 'checkjs' or null;
  vitest: true,
  eslint: true,
  prettier: true,
  playwright: false,
};
