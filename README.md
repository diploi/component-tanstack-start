<img alt="icon" src=".diploi/icon.svg" width="32">

# TanStack Start Component for Diploi

[![launch with diploi badge](https://diploi.com/launch.svg)](https://diploi.com/component/tanstack-start)
[![component on diploi badge](https://diploi.com/component.svg)](https://diploi.com/component/tanstack-start)
[![latest tag badge](https://badgen.net/github/tag/diploi/component-tanstack-start)](https://diploi.com/component/tanstack-start)

Launch a trial, no account needed
https://diploi.com/component/tanstack-start

Runs on Diploi's Node.js base image ([component-bases](https://github.com/diploi/component-bases)), which is built on the official [node](https://hub.docker.com/_/node) image.

A minimal setup to get [TanStack Start](https://tanstack.com/start/latest) working in Diploi, with React, file-based routing from [TanStack Router](https://tanstack.com/router/latest) and [Tailwind CSS](https://tailwindcss.com/). Server-side rendering is handled by [Nitro](https://nitro.build/), preconfigured through its Vite plugin in `vite.config.ts`.

## Operation

### Getting started

1. In the Dashboard, click **Create Project +**
2. Under **Pick Components**, choose **TanStack Start**

   You can add other frameworks from this page if you want to build a monorepo application, eg, TanStack Start for the frontend and Hono for the backend.
3. In **Pick Add-ons**, select any databases or extra tools you need.
4. Choose **Create Repository** so Diploi generates a new GitHub repo for your project.
5. Click **Launch Stack**

### Package managers

Supports **Bun**, **Yarn**, **npm**, and **pnpm**. The package manager is the one `packageManager` in your `package.json` names, or else the one your lockfile belongs to (`bun.lock`, `pnpm-lock.yaml`, `yarn.lock` or `package-lock.json`). The install and build steps always use it, at the version `packageManager` names.

### Development

When the component is first initialized, dependencies are installed using the detected package manager. The development server is then started with:

```sh
npm run dev
```

This can be changed with the `containerCommands.developmentStart` field in `diploi.yaml`.

### Production

Staging and production build the deployment's commit on the deployment itself, with the deployment's environment variables: dependencies are installed with the detected package manager, then `npm run build` runs `vite build`, which writes the Nitro server to `.output/`. A commit is built once; a restart of the component reuses the build. A failed build leaves the previous version running, and its log is shown on the deployment page, where the commit can also be built again.

The component then runs `npm start`, which starts the Nitro server:

```sh
node .output/server/index.mjs
```

This can be changed with the `containerCommands.productionStart` field in `diploi.yaml`. See [Ports](#ports).

In staging and production the project folder is read-only while the server runs, so the server cannot write files next to its code. Keep data in a database or another component, and use `/tmp` for a file needed only during one request.

#### ENV

TanStack Start reads [environment variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables) at two different times:

1. **When the server runs.** Server code, such as server functions (`createServerFn`), server routes and middleware, reads `process.env` while the server runs. Use it for secrets, and for values that depend on a specific deployment (such as variables imported from other components in `diploi.yaml`, or configured in the **Environment** tab).
2. **When the app is built.** `import.meta.env.VITE_*` is replaced during the build step. Only variables with the `VITE_` prefix reach code that runs in the browser, and everything they contain is visible there, so never give a secret a `VITE_` name. The build runs with every environment variable of the deployment, so a `VITE_` variable can hold a deployment's value too, such as another component's public `<HOST>_ENDPOINT`. A changed value builds the commit again.

A value read in a server function and returned from there, as in the [runtime client environment variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables#runtime-client-environment-variables-in-production) guide, changes without a new build.

To use a variable from another component in your code, import it in `diploi.yaml`. For example, to call a backend with the `api` identifier from server code:

```yaml
- name: TanStack Start
  identifier: tanstack-start
  env:
    include:
      - api.APP_INTERNAL_ENDPOINT:API_URL
```

Server code can use the `<HOST>_INTERNAL_ENDPOINT` address of a component, which stays inside the deployment. Code that runs in the browser needs the public `<HOST>_ENDPOINT` address.

#### System packages

The image has no packages beyond Node.js, Bun and pnpm. Install more with `initScript` in `diploi.yaml`, which runs as root when the component starts, or `preBuildScript`, which runs only before the build:

```yaml
- name: TanStack Start
  identifier: tanstack-start
  package: https://github.com/diploi/component-tanstack-start#main
  initScript: |
    apt-get update && apt-get install -y --no-install-recommends imagemagick
```

#### Ports

The component serves on port **5173** in every stage. To use another one, change the `port` of its `app` host in `diploi.yaml` (`hosts: [{ identifier: app, port: 8080 }]`). Diploi passes that port to the app as the `PORT` environment variable: the development server (`server.port` in `vite.config.ts`) and the Nitro server in staging and production listen on it.

A `containerCommands.productionStart` of your own should listen on `$PORT` too. Staging and production count a new version as ready once it accepts connections on that port: one that listens elsewhere never becomes ready, and the previous version keeps serving.

## Links

- [Adding TanStack Start to a project](https://docs.diploi.com/building/components/tanstack-start)
- [TanStack Start documentation](https://tanstack.com/start/latest)
- [TanStack Router documentation](https://tanstack.com/router/latest)
- [React documentation](https://react.dev/)
- [Vite documentation](https://vite.dev/)
- [Nitro documentation](https://nitro.build/)
