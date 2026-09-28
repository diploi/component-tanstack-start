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
- Serves on port **5173** in every stage. The port is set in `hosts[].port` in `diploi.yaml`, `EXPOSE`/`ENV PORT` in
  `Dockerfile` and `Dockerfile.dev`, and the fallback of `server.port` in `vite.config.ts`. Keep them in sync. The
  development server gets it from `server.port`, which reads `PORT`, and the Nitro server reads `PORT` itself.
- Development runs `npm run dev -- --host` (`Dockerfile.dev`). Staging and production run `npm run build`, which is
  `vite build` and writes the Nitro server to `.output/`, **not** `dist/`, and then `npm start`, which is
  `node .output/server/index.mjs` (`Dockerfile`).
- The development server already allows the Diploi hosts. Add any other host to `server.allowedHosts` in
  `vite.config.ts`, and never set it to `true`.
- `vite build` does not type-check, so a type error does not fail the build. Run `npx tsc --noEmit` for that.
  `npm run lint` runs ESLint with `@tanstack/eslint-config` (`eslint.config.js`), and `npm run check` only checks
  formatting with Prettier.

## Environment variables

TanStack Start reads env vars at two different times:

- Server code (server functions, server routes, middleware) reads `process.env` while the server runs, so it has the
  deployment's values, secrets included. Read them inside the handler, never at the top level of a module, which
  also runs in the browser.
- `import.meta.env.VITE_*` is replaced when `vite build` runs. It is the only way an env var reaches code in the
  browser, and everything in it is public, so never give a secret a `VITE_` name.
- There is no runtime build in this component. Staging and production build when the image is built, before the
  deployment's env vars exist, so a `VITE_` variable only has the static values from `diploi.yaml`, and `vite build`
  only sees those once they are declared with `ARG` in the `builder` stage of `Dockerfile`. In development, the
  development server has the deployment's values, so a `VITE_` variable that works there can still be empty in
  staging and production.
- For a value that depends on the deployment in the browser, such as another component's public `<HOST>_ENDPOINT`,
  read it with `process.env` in a server function and return it from there, as in TanStack Start's
  [runtime client environment variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables#runtime-client-environment-variables-in-production).
  Server code can call another component at its `<HOST>_INTERNAL_ENDPOINT`.

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
