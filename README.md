<img alt="icon" src=".diploi/icon.svg" width="32">

# TanStack Start Component for Diploi

[![launch with diploi badge](https://diploi.com/launch.svg)](https://diploi.com/component/tanstack-start)
[![component on diploi badge](https://diploi.com/component.svg)](https://diploi.com/component/tanstack-start)
[![latest tag badge](https://badgen.net/github/tag/diploi/component-tanstack-start)](https://diploi.com/component/tanstack-start)

Launch a trial, no account needed
https://diploi.com/component/tanstack-start

This template provides a minimal setup to get TanStack Start working in Diploi.

Uses the official [node](https://hub.docker.com/_/node) Docker image.

Server-side rendering is handled by [Nitro](https://nitro.build/), preconfigured through the TanStack Start Vite plugin.

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

Builds a production ready image. Image runs `npm install` & `npm run build` when being created, using the detected package manager. Once the image runs, `npm start` is called, which serves the Nitro build from `.output/`.

This can be changed with the `containerCommands.productionStart` field in `diploi.yaml`.

#### ENV

Since Vite replaces environment variables during the build step, the client side code cannot directly access dynamic ENVs in production.
You have a few ways to get around this limitation:

1. For values that are not deployment-dependent, define them in `diploi.yaml` using the [static import syntax](https://docs.diploi.com/reference/diploi-yaml#env). The values are exposed to the `Dockerfile` as `ARG` variables.
2. For values that depend on a specific deployment (such as variables imported from other components in `diploi.yaml`, or configured in the **Environment** tab), use the [recommended way to use runtime ENVs in production](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables#runtime-client-environment-variables-in-production) for TanStack Start.

#### Ports

The component serves on port **5173** in both development and production. If you change it, update all of these so they stay in sync:

- `hosts[].port` in `diploi.yaml`
- `EXPOSE` and `ENV PORT` in `Dockerfile` and `Dockerfile.dev`
- `server.port` in `vite.config.ts` — Vite does not read `PORT` from the environment on its own

## Links

- [Adding TanStack Start to a project](https://docs.diploi.com/building/components/tanstack-start)
- [TanStack Start documentation](https://tanstack.com/start/latest)
- [React documentation](https://react.dev/)
- [Vite documentation](https://vite.dev/)
- [Nitro documentation](https://nitro.build/)
