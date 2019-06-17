pipeline {
//    agent {
//        docker {
//            image 'maven:3-alpine'
//            args '-v /root/.m2:/root/.m2'
//        }
//   }
    agent {
        label 'master'
    }    
    environment {
        GIT_COMMIT_SHORT = sh(script: "printf \$(git rev-parse --short ${GIT_COMMIT})", returnStdout: true)
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
        isRelease = "${env.releaseBuild}"
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
          if (isRelease == 'true') {
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
//    stage('SonarQube Analysis') {
//      steps {
//         withSonarQubeEnv('SonarQube Scanner 2.8') {
//            // requires SonarQube Scanner for Maven 3.2+
//            sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.2:sonar'
//        }
//      }
//    }
    stage('Build') {
        steps {
            sh "mvn -B -DskipTests -Drevision=${CURRENT_REVISION} clean package"
        }
    }
    stage('Test') {
        steps {
            sh "mvn -Drevision=${CURRENT_REVISION} test"
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
            script {
                def revision = readYaml file: 'revision.yml'
                CURRENT_REVISION = "${revision.current.major}.${revision.current.minor}.${revision.current.patch}-${env.BUILD_ID}"
                writeYaml file: 'revision.copy.yaml', data: revision
            }              
        }
    }
    stage('Release') {
      when {
        expression {
          return isRelease == 'true'
        }
      }
      steps {
          // Git
          sh "git tag -a ${RELEASE_MAJOR_MINOR_PATCH} -m '${RELEASE_MAJOR_MINOR_PATCH}' ${RELEASE_COMMIT}"
          sh "git push origin --tags"    
        }          
    }
 }
}
