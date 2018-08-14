#!/bin/bash

count=1

while true; do
  echo "================================"
  echo "Beginning test ${count} build at $(date)"
  ./cycle.sh
  echo "Ending test ${count} build at $(date)"
  echo "================================"
  ((count++))
done
