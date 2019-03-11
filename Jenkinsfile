#!/usr/bin/env groovy

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                def sc = checkout scm
                sc.each{ k, v -> println "${k}:${v}" }
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