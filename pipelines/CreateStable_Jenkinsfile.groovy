#! /usr/bin/env groovy

node {

    stage('fabric-starter-rest') {
        stage('Checkout') {
            checkout([$class: 'GitSCM', branches: [[name: '*/master']],
                      doGenerateSubmoduleConfigurations: false, submoduleCfg: [],
                      extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'rest']],
                      userRemoteConfigs: [[credentialsId: 'test', url: "${REST_REPO}"]]])
        }
        stage("Build Stable") {
            echo "${PWD}"

            dir("rest") {
                sh "ls -l"
                def lastSnapshot=sh(returnStdout: true, script: "git branch -r --list 'origin/snapshot-*' --sort=-committerdate | head -1").trim()
                echo lastSnapshot
                def (branchPrefix, version, fabricVersion) = lastSnapshot.tokenize("-")
                echo version
                def (ver0, ver1)=version.tokenize(".")
                int v1=(ver1 as int)
                def newBranch="${branchPrefix}-${ver0}.${v1+1}-${fabricVersion}"
                echo newBranch

                def image
                docker.withRegistry('https://docker.io', 'dockerhub') {
                    image = docker.image('vrreality/fabric-starter-rest')
                    image.pull()
                    sh 'docker tag private-registry-1/my-image:tag private-registry-2/my-image:tag'
                }


            }

        }
        stage('fabric-starter') {
            checkout([$class: 'GitSCM', branches: [[name: '*/master']],
                      doGenerateSubmoduleConfigurations: false, submoduleCfg: [],
                      extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'starter']],
                      userRemoteConfigs: [[credentialsId: 'test', url: 'https://github.com/leonidle/fabric-starter']]])
        }

        stage('Build Stable') {

            echo "${PWD}"
            script {
                def lastSnapshot=sh("git branch -r --list 'origin/snapshot-*' --sort=-committerdate | head -1")
                echo lastSnapshot

            }
        }

    }


}