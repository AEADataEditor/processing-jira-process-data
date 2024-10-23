# README for building Docker

## Requirements

- Docker

## Build

The `Dockerfile` is used to build the Docker image. The image is built with the `build.sh` script, which requires a `TAG` argument, and will otherwise read parameters from the [`.myconfig.sh`](.myconfig.sh) file.

```bash
bash ./build.sh TAG
```

## Available Docker image (tags)

Use `ls-tags.sh` to list available tags.

```bash
bash ./ls-tags.sh
```


## Run

To run the image as a Rstudio interactive development image, use

```bash
bash ./start_rstudio.sh TAG
```

It defaults to the `2023-11-08` image if you don't specify a tag.

