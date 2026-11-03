# TanStack Start

A [TanStack Start](https://tanstack.com/start/latest) app with React and file-based routing from TanStack Router,
rendered on the server by [Nitro](https://nitro.build/) and styled with Tailwind CSS 4.

## This component

- Code is isomorphic by default: route loaders and components run on the server during SSR and in the browser after
  it. Put anything that needs a secret, a database or another component's internal address in a server function
  (`createServerFn`), a server route or middleware.
- Routes are the files in `src/routes/`. `src/routeTree.gen.ts` is generated from them by the `tanstackStart()` Vite
  plugin whenever the development server or a build runs, and by `npm run generate-routes` otherwise. Never edit it
  by hand.
- Listens on `PORT`, which Diploi sets to the port of the `app` host in `diploi.yaml` (**5173** unless changed): the
  development server through `server.port` in `vite.config.ts`, and the Nitro server by itself. To change the port,
  change only the host's `port`. Never hardcode one: staging and production count a version as ready once it accepts
  connections on `PORT`, and one that listens elsewhere never becomes ready.
- Development runs `npm run dev`. Staging and production build each commit on the deployment with `npm run build`,
  which is `vite build` and writes the Nitro server to `.output/`, **not** `dist/`, and then run `npm start`, which is
  `node .output/server/index.mjs`. In staging and production the project folder is read-only while the server runs,
  so server code never writes next to the code: a file needed only during one request goes to `/tmp`, data to a
  database or another component.
- The development server already allows the Diploi hosts. Add any other host to `server.allowedHosts` in
  `vite.config.ts`, and never set it to `true`.
- `vite build` does not type-check, so a type error does not fail the build. Run `npx tsc --noEmit` for that.
  `npm run lint` runs ESLint with `@tanstack/eslint-config` (`eslint.config.js`), and `npm run check` only checks
  formatting with Prettier.
- npm only runs a dependency's install script once the project approves it (`npm install-scripts approve <package>`,
  saved per version in `allowScripts` of `package.json`, so again after an upgrade), as pnpm (`onlyBuiltDependencies`)
  and Bun (`trustedDependencies`) do. A package that needs its script, such as Prisma for `prisma generate`, otherwise
  installs incomplete without an error: approve it when adding it.

## Environment variables

TanStack Start reads env vars at two different times:

- Server code (server functions, server routes, middleware) reads `process.env` while the server runs, so it has the
  deployment's values, secrets included. Read them inside the handler, never at the top level of a module, which
  also runs in the browser.
- `import.meta.env.VITE_*` is replaced when `vite build` runs. It is the only way an env var reaches code in the
  browser, and everything in it is public, so never give a secret a `VITE_` name.
- Staging and production build each commit on the deployment, with the deployment's env vars, once: a restart reuses
  the build, and a changed env var or a new commit builds again. So a `VITE_` variable has the deployment's value,
  for example another component's public `<HOST>_ENDPOINT` imported under a `VITE_` name. If the build fails, the
  previous version keeps running and the deployment page shows the log, so run `npm run build` before calling a
  change done.
- A value read with `process.env` in a server function and returned from there, as in TanStack Start's
  [runtime client environment variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables#runtime-client-environment-variables-in-production),
  changes without a build. Server code can call another component at its `<HOST>_INTERNAL_ENDPOINT`.
- The image holds no code and no Dockerfile is in the project. System packages go into `initScript` (every start, as
  root) or `preBuildScript` (only the build) of the component in `diploi.yaml`.

## TanStack AI tools

TanStack ships its guidance for agents as [TanStack Intent](https://tanstack.com/intent/latest) skills inside its npm
packages, so they match the installed versions. Run the Intent commands in this component's folder, where
`package.json` and `node_modules` are: that is the "workspace root" in the instructions below. Start with
`npx @tanstack/intent@latest load @tanstack/start-client-core#start-core`. Its `start-core/execution-model` sub-skill
covers where code runs and environment variables.

TanStack also publishes its documentation for LLMs at <https://tanstack.com/start/latest/llms.txt> and
<https://tanstack.com/router/latest/llms.txt>. Its pages are also available as Markdown, with `.md` added to the URL.

The official TanStack Intent instructions follow. Keep the markers around them, so that
`npx @tanstack/intent@latest install` can update them.

<!-- intent-skills:start -->
## Skill Loading

Before editing files for a substantial task:
- Run `npx @tanstack/intent@latest list` from the workspace root to see available local skills.
- If a listed skill matches the task, run `npx @tanstack/intent@latest load <package>#<skill>` before changing files.
- Use the loaded `SKILL.md` guidance while making the change.
- Monorepos: when working across packages, run the skill check from the workspace root and prefer the local skill for the package being changed.
- Multiple matches: prefer the most specific local skill for the package or concern you are changing; load additional skills only when the task spans multiple packages or concerns.
<!-- intent-skills:end -->
