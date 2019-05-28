#!/usr/bin/env groovy

// Parameters:
// DOCKER_REGISTRY: https://registry-1.docker.io/v2
// DOCKER_REPO: olegabu
// DOCKER_CREDENTIALS_ID: dockerhub
//
// GIT_REPO_OWNER: olegabu
// GITHUB_SSH_CREDENTIALS_ID: github

// FABRIC_VERSION: 1.4




def evaluateNextSnapshotGitTag(repoTitle) {
    echo "Evaluate next snapshot name for ${repoTitle}"
    def lastSnapshot = sh(returnStdout: true, script: "git branch -r --list 'origin/snapshot-*' --sort=-committerdate | head -1").trim()
    echo "Current latest snapshot: ${lastSnapshot}"
    def (branchPrefix, version, fabricVersion) = lastSnapshot.tokenize("-")
    def (majorVer, minorVer) = version.tokenize(".")
    int minorVersion = (minorVer as int)
    def newGitTag = "${branchPrefix}-${majorVer}.${minorVersion + 1}-${fabricVersion}"

    newTag = newGitTag.split("/")[1]
    echo "New Tag for ${repoTitle}: ${newTag}"
    newTag
}

node {

    stage('Fabric-Starter-Rest') {
        def newFabricStarterRestTag
        stage('Checkout Fabric-starter-rest') {
            checkout([$class                           : 'GitSCM', branches: [[name: '*/master']],
                      doGenerateSubmoduleConfigurations: false, submoduleCfg: [],
                      extensions                       : [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'fabric-starter-rest']],
                      userRemoteConfigs                : [[credentialsId: "${GITHUB_SSH_CREDENTIALS_ID}", url: "git@github.com:${GIT_REPO_OWNER}/fabric-starter-rest.git"]]])
        }
        stage("Build Stable docker image of fabric-starter-rest") {
            dir("fabric-starter-rest") {
                echo "PWD: ${PWD}"
                newFabricStarterRestTag = evaluateNextSnapshotGitTag('Fabric-starter-rest')
                docker.withRegistry("${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                    def image = docker.image('${DOCKER_REPO}/fabric-starter-rest:latest')
                    image.pull()
                    sh "docker tag ${DOCKER_REPO}/fabric-starter-rest:latest ${DOCKER_REPO}/fabric-starter-rest:${newFabricStarterRestTag}"
                    image = docker.image("${DOCKER_REPO}/fabric-starter-rest:${newFabricStarterRestTag}")
                    //image.push()
                }
            }
        }
        stage('Snapshot fabric-starter-rest') {
            dir('fabric-starter-rest') {
                sshagent(credentials: ["${GITHUB_SSH_CREDENTIALS_ID}"]) {
                    sh "git checkout -B ${newFabricStarterRestTag}"
                    sh("git push -u origin ${newFabricStarterRestTag}")
                }
            }

        }

        stage('Fabric-Starter-Rest') {
            stage('Snapshot fabric-starter') {
                checkout([$class                           : 'GitSCM', branches: [[name: '*/master']],
                          doGenerateSubmoduleConfigurations: false, submoduleCfg: [],
                          extensions                       : [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'fabric-starter'], [$class: 'UserIdentity', name: "${GIT_REPO_OWNER}"]],
                          userRemoteConfigs                : [[credentialsId: "${GITHUB_SSH_CREDENTIALS_ID}", url: "git@github.com:${GIT_REPO_OWNER}/fabric-starter.git"]]])

                dir('fabric-starter') {
                    echo "PWD: ${PWD}"
                    def newFabricStarterTag = evaluateNextSnapshotGitTag('Fabric-starter')
                    sshagent(credentials: ["${GITHUB_SSH_CREDENTIALS_ID}"]) {
                        sh "git checkout -B ${newFabricStarterTag}"
                        def envFileContent = readFile '.env'
                        writeFile file: '.env', text: "${envFileContent}\nFABRIC_STARTER_REST_VERSION=${newFabricStarterRestTag}\nFABRIC_VERSION=${FABRIC_VERSION}"
                        sh "git add .env"
                        sh "git commit -m \'Snapshot ${newFabricStarterTag}\'"
                        sh("git push -u origin ${newFabricStarterTag}")
                    }
                }
            }
        }
    }
}


