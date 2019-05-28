
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

                def newTag=newBranch.split("/")[1]
                echo "New Tag:  ${newTag}"

                docker.withRegistry('https://registry-1.docker.io/v2', 'dockerhub') {
                    def image = docker.image('vrreality/fabric-starter-rest:latest')
                    image.pull()
                    sh "docker tag vrreality/fabric-starter-rest:latest vrreality/fabric-starter-rest:${newTag}"
                    image = docker.image("vrreality/fabric-starter-rest:${newTag}")
                    image.push()
                }
                sh "git checkout -b ${newTag}"
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