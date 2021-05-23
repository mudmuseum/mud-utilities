#!/usr/bin/env bash

# Ensure we're specifying a target file
if [[ ! -z ${1} ]] && [[ -f ${1} ]]; then

  # Ensuring we have a set of themes to generate
  if [[ -f themes.sh ]]; then
    echo "1. Sourcing themes list."
    source themes.sh

    echo "2. Preparing output directory."
    TIMESTAMP=$(date +%s)
    OUTPUT_DIR="./outputs/${1}_${TIMESTAMP}"
    mkdir -p ${OUTPUT_DIR}

    echo "3. Generating diagrams in different themes."
    for theme in ${THEMES[@]}; do
      echo "  Generating theme ${theme}."
      sed 's/THEME/'"${theme}"'/' ${1} > ${1}.${theme}.adj.txt
      java -jar plantuml.jar ${1}.${theme}.adj.txt -o ${OUTPUT_DIR}/ &
    done

    echo "Themes generated into '${OUTPUT_DIR}/'."
    while [[ `jobs | wc -l` -ge 1 ]]; do
      echo "Waiting for jobs to finish..."
      sleep 1
      jobs > /dev/null
    done
    # Cleanup
    rm ${1}.*.adj.txt
  fi
fi
