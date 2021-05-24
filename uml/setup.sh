#!/usr/bin/env bash

# Download the latest plantuml JAR
curl -L http://sourceforge.net/projects/plantuml/files/plantuml.jar/download -o plantuml.jar

java -jar plantuml.jar -version
