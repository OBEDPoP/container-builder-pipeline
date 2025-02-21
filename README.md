# GitHub Actions: Automated Docker Image Build and Artifactory push

This repository contains a GitHub Actions pipeline that automates the process of building and deploying Docker images for various types of projects. It supports multiple languages, multi-stage builds, and integration with different container registries (Artifactory/DockerHub).

## Prerequisites

Before running the GitHub Actions pipeline, ensure the following requirements are met:

1. **Manifest File (********`manifest.yaml`********\*\*\*\*)**: This file must be present in the root of your repository, specifying details about the Docker image build.
2. **Project-Specific Dependencies**:
   - For **Node.js** projects: `package.json`
   - For **Python** projects: `requirements.txt`
   - For **Java** projects: `pom.xml` or `build.gradle`
   - For **Go** projects: `go.mod`
   - For **Other projects**: Ensure respective build files are available.
3. **GitHub Secrets for Registry Authentication** (if pushing to a private registry).

## `manifest.yaml` Example

The `manifest.yaml` file should include the following structure:

```yaml
- appname: docker_build
  tag: docker_build:latest
  multistage: yes 
  Expose: 3000 
  Env Variables: 
    - endpoint: docker.io 
      pass: {xxxxxxxxxx.key.com}
```

## Inputs for GitHub Actions

When triggering the workflow manually, provide the following inputs:

| Parameter           | Description                                | Required | Default |
| ------------------- | ------------------------------------------ | -------- | ------- |
| `repo_url`          | Git Repository URL                         | ✅ Yes    | -       |
| `branch`            | Branch Name                                | ❌ No     | `main`  |
| `github_username`   | GitHub Username (for private repositories) | ❌ No     | -       |
| `github_token`      | GitHub Token (for private repositories)    | ❌ No     | -       |
| `registry_url`      | Registry URL (Artifactory/DockerHub)       | ❌ No     | -       |
| `registry_username` | Registry Username                          | ❌ No     | -       |
| `registry_password` | Registry Password                          | ❌ No     | -       |

## Running the GitHub Actions Workflow

1. Ensure your repository contains the required files (`manifest.yaml`, language-specific dependencies).
2. Navigate to the **GitHub Actions** tab in your repository.
3. Select the **Build and Deploy Docker Images** workflow.
4. Manually trigger the workflow by entering the required inputs.
5. The pipeline will:
   - Parse `manifest.yaml` to determine build configurations.
   - Generate a `Dockerfile` (if not present) using `generate_dockerfile.sh`.
   - Build the Docker image.
   - Push the image to the specified container registry or save it as an artifact.

## Script Details and Advantages

### Script: `generate_dockerfile.sh`

- **Project Detection**: Automatically detects the type of project by checking for specific files (e.g., `package.json`, `requirements.txt`).
- **Dockerfile Generation**: Creates a `Dockerfile` if it doesn't exist, tailored to the detected project type.
- **Multi-Stage Build**: Adds multi-stage build configurations if specified in `manifest.yaml`.
- **Additional Configurations**: Appends exposed ports and environment variables to the `Dockerfile` based on `manifest.yaml`.

### Advantages

✅ **Automation**: Streamlines the process of building and deploying Docker images, reducing manual effort.
✅ **Flexibility**: Supports various programming languages and project types.
✅ **Customization**: Allows custom configurations via `manifest.yaml`.
✅ **Security**: Handles credentials securely using GitHub Secrets.
✅ **Ease of Use**: Simple setup and usage with clear instructions.

---

Feel free to copy the code and reuse it, or make edits in different branches, contributions are welcomed!

\----------------------Copyright © 2025 OBED PAUL | All Rights Reserved----------------------
