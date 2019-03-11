#!/usr/bin/env groovy

pipeline {
    agent
    node {
        label 'generic'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('Build') {
            steps {

                sh 'pwd'
                sh 'ls ..'
            }
        }
/*        stage('Test') {
            steps {
                //
            }
        }
        stage('Deploy') {
            steps {
                //
            }
        }*/
    }
}