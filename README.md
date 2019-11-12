# docker-node-8-rsync-python-ssh
Node 8 container with rsync, python and ssh support


## Example how to use this image in GitLab CI/CD

1. Create file `.gitlab-ci.yml`, e.g.:
```
image: kirbownz/node8-rsync-python-ssh

###### STAGES #################################################################
stages:
  - install
  - test
  - build
  - deploy

###### TEMPLATES ##############################################################
.general: &general
  variables:
    GIT_STRATEGY: fetch

variables:
  # Docker in Docker variables
  DOCKER_HOST: "tcp://docker:2375"

###### JOBS ###################################################################
install:
  <<: *general
  stage: install
  artifacts:
    paths:
      - node_modules
    expire_in: 1 day
  script:
    - rm yarn.lock
    - yarn

test:
  <<: *general
  stage: test
  dependencies:
    - install
  script:
    - yarn test

build:
  <<: *general
  stage: build
  dependencies:
    - install
  artifacts:
    paths:
      - build
    expire_in: 1 week
  script:
    - yarn build

deployment:
  <<: *general
  stage: deploy
  dependencies:
    - build
  script:
    - mkdir -p ~/.ssh
    - echo "${ssh_key}" > ~/.ssh/id_rsa
    - chmod 700 ~/.ssh
    - chmod 600 ~/.ssh/id_rsa
    - echo "${gitconfig}" > ~/.gitconfig
    - ssh-keyscan -t rsa ${demo_host} >> ~/.ssh/known_hosts
    - rsync build/ ${demo_user}@${demo_host}:${demo_path} --delete-after -r -v
```
2. Add the variables above in GitLab -> Project -> Settings -> CI / CD -> Variables:

| Type | Key | Value | Protected | Masked | Scope |
|------|-----|-------|-----------|--------|-------|
| Variable | `demo_host` | `example.com` | - | - | All environments |
| Variable | `demo_path` | `~/project/dist/` | - | - | All environments |
| Variable | `demo_user` | `user` | - | - | All environments |
| Variable | `gitconfig` | `[user]`<br>`name = Firstname Lastname`<br>`email = email@me.com` | - | - | All environments |
| Variable | `ssh_key` | `-----BEGIN RSA...` | - | - | All environments |
