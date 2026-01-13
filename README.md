# Heroku Buildpack for Heroku AppLink Service Mesh

This buildpack installs [Heroku AppLink Service Mesh](https://github.com/heroku/heroku-applink-service-mesh) in a Heroku app. This buildpack, and the binary it installs, is to be used in conjunction with Heroku AppLink add-on.

For more information, see [Heroku AppLink](https://devcenter.heroku.com/articles/heroku-applink).

## Installation

```shell
heroku buildpacks:add heroku/heroku-applink-service-mesh
```

## Usage

The Heroku AppLink Service Mesh binary must be configured in your Procfile web process to start your app.

> [!IMPORTANT]
> The Heroku AppLink Service Mesh binary automatically binds to the default Heroku web `$PORT`. To ensure the mesh can route traffic to your application, you must configure your app to listen on a secondary port. Use the `APP_PORT` environment variable in your Procfile’s web command; this variable is read by both the Service Mesh and your application to establish the connection.

```shell
web: APP_PORT=<app port> heroku-applink-service-mesh <your app startup command>
```

For example, for Nodejs apps:
```shell
web: APP_PORT=3000 heroku-applink-service-mesh npm start
```
Nodejs app binds to port `3000`.

Java apps:
```shell
web: APP_PORT=3000 heroku-applink-service-mesh -- java $JAVA_OPTS -jar target/app-0.0.1-SNAPSHOT.jar
```
Java app binds to port `3000`.

Python apps:
```shell
web: heroku-applink-service-mesh --port $PORT -- uvicorn app:app --port 3000
```
Python app binds to port `3000`.


On each app build, the buildpack will retrieve and install the latest release version of the binary.

To declare a specific release version or tag set `HEROKU_APPLINK_SERVICE_MESH_RELEASE_VERSION` config or environment variable.

```shell
HEROKU_APPLINK_SERVICE_MESH_RELEASE_VERSION=v1.0.0
```

During deployment, Heroku AppLink Service Mesh binary is installed.

```shell
-----> Installing version "v1.0.0" of Heroku AppLink Service Mesh...
       Downloading heroku-applink-service-mesh...
       Installing heroku-applink-service-mesh...
       Done!
-----> Ensure that heroku-applink-service-mesh is configured in your Procfile's web process to start your app, eg heroku-applink-service-mesh <app startup command>
```

## Run Locally

```shell
$ git clone git@github.com:heroku/heroku-buildpack-heroku-applink-service-mesh.git
...
$ cd heroku-buildpack-heroku-applink-service-mesh
$ mkdir build_dir cache_dir env_dir
$ bin/compile build_dir cache_dir env_dir/
-----> Installing version "v0.12.1" of Heroku AppLink Service Mesh...
       Downloading heroku-applink-service-mesh...
       Installing heroku-applink-service-mesh...
       Done!
-----> Ensure that heroku-applink-service-mesh is configured in your Procfile's web process to start your app, eg heroku-applink-service-mesh <app startup command>
$ ls -l build_dir/vendor/heroku-applink/bin/
total 12M
-rwxrwxr-x 1 cwall cwall 12M Sep 27 07:55 heroku-applink-service-mesh

```
