<img alt="icon" src=".diploi/icon.svg" width="32">

# TanStack Start Component for Diploi

[![launch with diploi badge](https://diploi.com/launch.svg)](https://diploi.com/component/tanstack-start)
[![component on diploi badge](https://diploi.com/component.svg)](https://diploi.com/component/tanstack-start)
[![latest tag badge](https://badgen.net/github/tag/diploi/component-tanstack-start)](https://diploi.com/component/tanstack-start)

Launch a trial, no account needed
https://diploi.com/component/tanstack-start

Uses the official [node](https://hub.docker.com/_/node) Docker image.

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

Supports **Bun**, **Yarn**, **npm**, and **pnpm**. The package manager is auto-detected from your lockfile (`bun.lock`, `yarn.lock`, `package-lock.json`, or `pnpm-lock.yaml`). The install and build steps always use the detected package manager.

### Development

When the component is first initialized, dependencies are installed using the detected package manager. The development server is then started with:

```sh
npm run dev -- --host
```

This can be changed with the `containerCommands.developmentStart` field in `diploi.yaml`.

### Production

Builds a production-ready image. Image runs `npm install` & `npm run build` when being created, using the detected package manager. `vite build` writes the Nitro server to `.output/`.

Once the image runs, `npm start` is called, which starts the Nitro server:

```sh
node .output/server/index.mjs
```

This can be changed with the `containerCommands.productionStart` field in `diploi.yaml`.

#### ENV

TanStack Start reads [environment variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables) at two different times:

1. **When the server runs.** Server code, such as server functions (`createServerFn`), server routes and middleware, reads `process.env` while the server runs. Use it for secrets, and for values that depend on a specific deployment (such as variables imported from other components in `diploi.yaml`, or configured in the **Environment** tab).
2. **When the app is built.** `import.meta.env.VITE_*` is replaced during the build step. Only variables with the `VITE_` prefix reach code that runs in the browser, and everything they contain is visible there, so never give a secret a `VITE_` name. The build runs when the image is created, so only use these for values that are not deployment-dependent, and define those in `diploi.yaml` using the [static import syntax](https://docs.diploi.com/reference/diploi-yaml#env). The values are exposed to the `Dockerfile` as `ARG` variables.

To use a deployment-dependent value in the browser, read it in a server function and return it from there, as in the [runtime client environment variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables#runtime-client-environment-variables-in-production) guide.

To use a variable from another component in your code, import it in `diploi.yaml`. For example, to call a backend with the `api` identifier from server code:

```yaml
- name: TanStack Start
  identifier: tanstack-start
  env:
    include:
      - api.APP_INTERNAL_ENDPOINT:API_URL
```

Server code can use the `<HOST>_INTERNAL_ENDPOINT` address of a component, which stays inside the deployment. Code that runs in the browser needs the public `<HOST>_ENDPOINT` address.

#### Ports

The component serves on port **5173** in both development and production. If you change it, update all of these so they stay in sync:

- `hosts[].port` in `diploi.yaml`
- `EXPOSE` and `ENV PORT` in `Dockerfile` and `Dockerfile.dev`. The production server reads `PORT`
- The fallback of `server.port` in `vite.config.ts`, which the development server uses when `PORT` is not set

## Links

- [Adding TanStack Start to a project](https://docs.diploi.com/building/components/tanstack-start)
- [TanStack Start documentation](https://tanstack.com/start/latest)
- [TanStack Router documentation](https://tanstack.com/router/latest)
- [React documentation](https://react.dev/)
- [Vite documentation](https://vite.dev/)
- [Nitro documentation](https://nitro.build/)
