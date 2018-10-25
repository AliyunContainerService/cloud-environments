pipeline {
    agent any
    environment {
        GH_CREDS = credentials('jenkins-x-github')
        GKE_SA = credentials('gke-sa')
        GHE_CREDS = credentials('ghe-test-user')
        JENKINS_CREDS = credentials('test-jenkins-user')
        GIT_PROVIDER_URL = "https://github.beescloud.com"
    }
    stages {
        stage('CI Build') {
            when {
                branch 'PR-*'
            }
            environment {
                CLUSTER_NAME = "JXCE-$BRANCH_NAME-$BUILD_NUMBER"
                ZONE = "europe-west1-c"
                PROJECT_ID = "jenkinsx-dev"
                SERVICE_ACCOUNT_FILE = "$GKE_SA"
                GHE_TOKEN = "$GHE_CREDS_PSW"
                JENKINS_PASSWORD="$JENKINS_CREDS_PSW"

                JX_DISABLE_DELETE_APP  = "true"
                JX_DISABLE_DELETE_REPO = "true"
            }
            steps {
                sh "jx step git credentials"
                dir ('/home/jenkins/go/src/github.com/jenkins-x/godog-jx'){
                    git "https://github.com/jenkins-x/godog-jx"
                    sh "make configure-ghe"
                }
                sh "./jx/scripts/ci-gke.sh"
                sh "jx version -b"

                // lets test we have the jenkins token setup
                sh "jx get pipeline"
                
                dir ('/home/jenkins/go/src/github.com/jenkins-x/godog-jx'){
                    git "https://github.com/jenkins-x/godog-jx"
                    sh "make bdd-tests"
                }
            }
        }

        stage('Build and Push Release') {
            when {
                branch 'master'
            }
            steps {
                // auto upgrade demo env
                echo 'auto upgrades not yet implemented'
            }
        }
    }
}
