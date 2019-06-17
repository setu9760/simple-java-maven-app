pipeline {
//    agent {
//        docker {
//            image 'maven:3-alpine'
//            args '-v /root/.m2:/root/.m2'
//        }
//   }
    environment {
        ARTIFACT_ID = readMavenPom().getArtifactId()
        OWNER = 'platform'
        IMAGE_NAME = "${OWNER}/${ARTIFACT_ID}"
        CURRENT_REVISION = ''
        RELEASE_MAJOR = ''
        RELEASE_MINOR = ''
        RELEASE_PATCH = ''
        RELEASE_MAJOR_MINOR = ''
        RELEASE_MAJOR_MINOR_PATCH = ''
        RELEASE_BUILD = ''
        RELEASE_COMMIT = ''
        RELEASE_REVISION = ''
        dockerImage = ''
        isRelease = false
    }
    tools {
        maven 'Maven 3.5.3'
        jdk 'Java8'
    }

    stages {
                stage('List change sets') {
          steps {
            script {
              def changeLogSets = currentBuild.changeSets
              for (int i = 0; i < changeLogSets.size(); i++) {
                def entries = changeLogSets[i].items
                for (int j = 0; j < entries.length; j++) {
                  def entry = entries[j]
                  echo "${entry.commitId} by ${entry.author} on ${new Date(entry.timestamp)}: ${entry.msg}"
                  def files = new ArrayList(entry.affectedFiles)
                  for (int k = 0; k < files.size(); k++) {
                    def file = files[k]
                    echo "  ${file.editType.name} ${file.path}"
                    // Check if we are releasing
                    if (file.path.equals("revision.yml")) {
                      isRelease = true
                    }
                  }
                }
              }
            }
          }
        }
    stage('Read revision metadata') {
      steps {
        script {
          def revision = readYaml file: 'revision.yml'
          CURRENT_REVISION = "${revision.current.major}.${revision.current.minor}.${revision.current.patch}-${env.BUILD_ID}"
          currentBuild.displayName = "${CURRENT_REVISION}"
          echo "Current revision: ${CURRENT_REVISION}"
          if (isRelease == true) {
            RELEASE_MAJOR = "${revision.release.major}"
            RELEASE_MINOR = "${revision.release.minor}"
            RELEASE_PATCH = "${revision.release.patch}"
            RELEASE_MAJOR_MINOR = "${RELEASE_MAJOR}.${RELEASE_MINOR}"
            RELEASE_MAJOR_MINOR_PATCH = "${RELEASE_MAJOR_MINOR}.${RELEASE_PATCH}"
            RELEASE_BUILD = "${revision.release.build}"
            RELEASE_COMMIT = "${revision.release.commit}"
            RELEASE_REVISION = "${RELEASE_MAJOR_MINOR_PATCH}-${RELEASE_BUILD}-${RELEASE_COMMIT}"
          }
        }
      }
    }
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Deliver') {
            steps {
                sh './jenkins/scripts/deliver.sh'
            }
        }
    }
}
