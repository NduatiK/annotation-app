# Image Annotation Web App

[![][badge-license]][license]

[badge-license]: https://img.shields.io/badge/license-MPL--2.0-blue.svg?style=flat-square
[license]: https://www.mozilla.org/en-US/MPL/2.0/

This repository is a fully customizable image annotation web application.
It is based on the Elm package
[mpizenberg/elm-image-annotation][image-anotation].
This work is in the process of being submitted to [ACM MM'18 OSS Competition][mm18-ossc].

[image-anotation]: https://github.com/mpizenberg/elm-image-annotation
[mm18-ossc]: http://www.acmmm.org/2018/open-source-software-competition/

![](https://mpizenberg.github.io/resources/annotation-app/banner-thin.jpg)


## Usage

The image annotation application is a web application.
At the time of writing this, the application is deployed
at http://annotation-app.pizenberg.fr so the simplest way
of using it is to follow the link in your browser.
If the application is down or you are interested in running
it locally, check the Installation section.

To open images to annotate, click on the image icon in the top toolbar.
You can select one or multiple images.
Repeating this action will add other images.

Then, click on the config button in the top toolbar and load a Json config file.
A config file describes the annotation tools and the labels you want to use.
Let's say that we want to annotate humans, dogs and cats, with bounding boxes.
Then the Json config file will be:

```json
{ "classes": [ "human", "dog", "cat" ]
, "annotations": [ "bbox" ]
}
```

You can put any class you want and subclasses.
The annotation types available are:

* Bounding boxes: "bbox"
* Points: "point"
* Strokes: "stroke"
* Outlines: "outline"
* Polygons: "polygon"

The config syntax is described with more details in the app documentation.
The resulting interface with previous Json will be as the following image.

![](https://mpizenberg.github.io/resources/annotation-app/simple-config.jpg)

> **Warning**: you can change the config at any time but beware that
> any config change will reset the annotations already done.


* Export annotations
* More documentation on gitbook


## Installation

There are two suggested way of installation if you want to run the app locally.
Prefer to use npm if you want to modify some code,
or docker if you simply want to use the app.

### Using docker installation

In case the online app is not available or you prefer to run it locally,
the simplest way to do so is to run the app in a docker container.
First you need to have docker installed on your machine.
See [docker installation documentation][docker-install].
Once you have installed docker on your machine, start the container with:

```shell
docker run -d -p 80:8003 mpizenberg/annotation-app:app
```

Then simply open the app in your browser at `localhost`.

> **Windows notice**: if you are using Docker Toolbox,
> use the Docker Machine IP instead of `localhost`.
> For example, `http://192.168.99.100`.
> To find the IP address, use the command `docker-machine ip`.

When you want to stop the app, just like any other docker app, run:

```shell
docker stop <id>
```

Where `<id>` can be figured out by displaying currently running containers:

```shell
docker container ls
```

[docker-install]: https://docs.docker.com/install/

### Using npm installation

If you want to compile the source code you need to have **node with npm**,
and **elm** installed.
If you are here, chances are you already have them installed on your system.
Otherwise I suggest to install node/npm with [Node Version Manager (nvm)][nvm],
and then to install elm@0.18.0 using npm: `npm install -g elm@0.18.0`.
You can retrieve this application with **git** as explained below.
In case you do not have git on your system and wish not to install it,
you can download a zip folder containing the application at [this link][zip].

When dependencies are met, to retrieve, compile and run this application for the first time:

```shell
# Clone repository with submodule dependencies
# Alternatively, download https://github.com/mpizenberg/annotation-app/archive/master.zip
git clone --recursive https://github.com/mpizenberg/annotation-app.git

# Move into the repository
cd annotation-app

# Compile and run for the first time
make all
```

Then simply open your browser at `localhost:8003` to load the application.
After the first installation, I suggest to use `make run` instead of `make all`.
Finer grained make rules and configuration are available in the simple `Makefile`.

> **Windows notice**: This makefile uses posix shell syntax (sh, bash, dash, ...)
> for its rules. It is thus not compatible with Windows.
> Please refer to issue #14 if you are on Windows and wish to run
> this application this way.

[nvm]: https://github.com/creationix/nvm#install-script
[zip]: https://github.com/mpizenberg/annotation-app/archive/master.zip


## Contributors

If you want to contribute to this project,
the best way is to start by opening a github issue on this repo
or contacting me on the elm slack (user @mattpiz).

* Matthieu Pizenberg - @mpizenberg
* Axel Carlier


## Special thanks

I would like to thank the online Elm community in particular:

* @evancz for the delightful Elm language
* @ianmackenzie for his fantastic geometry library
* @mdgriffith for his very refreshing layout library
* @lukewestby for the amazing tool Ellie
* @norpan, @jessta, @loganmac, @antew, for their invaluable help on slack
