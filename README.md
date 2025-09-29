# Heroku Buildpack for Heroku AppLink Service Mesh

This buildpack installs [Heroku AppLink Service Mesh](https://github.com/heroku/heroku-applink-service-mesh) in a Heroku app. This buildpack, and the binary it installs, is to be used in conjunction with Heroku AppLink add-on.

For more information, see [Heroku AppLink](https://devcenter.heroku.com/articles/heroku-applink).

## Installation

```shell
heroku buildpacks:add heroku/heroku-applink-service-mesh
```

## Usage

The Heroku AppLink Service Mesh binary must be configured in your Procfile web process to start your app.

```shell
web: heroku-applink-service-mesh <your app startup command>
```

For example, for Nodejs apps:
```shell
web: APP_PORT=3000 heroku-applink-service-mesh npm start
```

Java apps:
```shell
web: APP_PORT=3000 heroku-applink-service-mesh -- java $JAVA_OPTS -jar target/app-0.0.1-SNAPSHOT.jar
```

Python apps:
```shell
web: heroku-applink-service-mesh --port $PORT -- uvicorn app:app --port 3000
```

The latest Heroku AppLink Service Mesh release will be installed.

To declare a specific release version or tag set `HEROKU_APPLINK_SERVICE_MESH_RELEASE_VERSION` config or environment variable.

```shell
HEROKU_APPLINK_SERVICE_MESH_RELEASE_VERSION=v1.0.0
```

During deployment, Heroku AppLink Service Mesh binary is installed.

```shell
-----> Installing version "v0.1.0" of Heroku AppLink Service Mesh...
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
