#!/bin/bash

# This file generates the Dockerfile for the build based on input

# Navigate to the repository directory
cd repo

# Identify project type
if [ -f "package.json" ]; then
  PROJECT_TYPE="node"
elif [ -f "requirements.txt" ]; then
  PROJECT_TYPE="python"
elif [ -f "pom.xml" ]; then
  PROJECT_TYPE="java"
elif [ -f "main.go" ]; then
  PROJECT_TYPE="go"
elif [ -f "Gemfile" ]; then
  PROJECT_TYPE="ruby"
elif [ -f "index.php" ]; then
  PROJECT_TYPE="php"
else
  echo "Unknown project type"
  exit 1
fi

# Parse manifest.yaml
if [ -f "manifest.yaml" ]; then
  APPNAME=$(yq e '.[0].appname' manifest.yaml)
  TAG=$(yq e '.[0].tag' manifest.yaml)
  MULTISTAGE=$(yq e '.[0].multistage' manifest.yaml)
  EXPOSE=$(yq e '.[0].Expose' manifest.yaml)
  ENV_VARS=$(yq e -o=j '.[0].Env Variables' manifest.yaml)
else
  echo "manifest.yaml not found"
  exit 1
fi

# Create Dockerfile if not exists
if [ ! -f "Dockerfile" ]; then
  case $PROJECT_TYPE in
    node)
      echo -e 'FROM node:14-alpine\nWORKDIR /app\nCOPY . .\nRUN npm install\nCMD ["npm", "start"]' > Dockerfile
      ;;
    python)
      echo -e 'FROM python:3.8-slim\nWORKDIR /app\nCOPY . .\nRUN pip install -r requirements.txt\nCMD ["python", "app.py"]' > Dockerfile
      ;;
    java)
      echo -e 'FROM openjdk:11-jre-slim\nWORKDIR /app\nCOPY target/*.jar app.jar\nCMD ["java", "-jar", "app.jar"]' > Dockerfile
      ;;
    go)
      echo -e 'FROM golang:1.16-alpine\nWORKDIR /app\nCOPY . .\nRUN go build -o main .\nCMD ["./main"]' > Dockerfile
      ;;
    ruby)
      echo -e 'FROM ruby:2.7\nWORKDIR /app\nCOPY . .\nRUN bundle install\nCMD ["ruby", "app.rb"]' > Dockerfile
      ;;
    php)
      echo -e 'FROM php:7.4-apache\nWORKDIR /var/www/html\nCOPY . .\nCMD ["apache2-foreground"]' > Dockerfile
      ;;
    *)
      echo "No template for project type"
      exit 1
      ;;
  esac
fi

# Adjust Dockerfile for multi-stage build and additional settings
if [ "$MULTISTAGE" == "yes" ]; then
  if [ "$PROJECT_TYPE" == "node" ]; then
    mv Dockerfile Dockerfile.tmp
    echo -e 'FROM node:14-alpine as build\nWORKDIR /app\nCOPY . .\nRUN npm install\n\nFROM node:14-alpine\nWORKDIR /app\nCOPY --from=build /app .\nCMD ["npm", "start"]' > Dockerfile
  fi
  # Add other multi-stage build configurations as needed
fi

if [ -n "$EXPOSE" ]; then
  echo "EXPOSE $EXPOSE" >> Dockerfile
fi

if [ -n "$ENV_VARS" ]; then
  echo "$ENV_VARS" | jq -r '.[] | "ENV \(.endpoint) \(.pass)"' >> Dockerfile
fi
