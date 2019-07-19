pipeline {
    agent any

    options { 
        disableConcurrentBuilds() 
    }
 
    triggers {
        pollSCM('H * * * *')
    }


    stages {
        stage('Build') {
            steps {

                echo 'Building...'
				
				script{
				
					if (fileExists('junk.sh')) {
                         archiveArtifacts 'junk.sh'
						echo 'Yes'
					}else {
						echo 'No'
                    }


                    try {
                        echo 'Forceing an error to test the try catch in JenkinsFile Build Stage'
                        error()
                    } catch (Exception e) {
                        echo e.toString()
                        echo 'Catching!'
                    }	
						
				}
				
            }
        }
		
		stage('Test') {
            steps {

                echo 'Testing...'
				
				
				script {
					def failure = powershell label: '', returnStatus: true, script: 'Get-Service "s*" | Format-Table'
					if(failure){
						error 'Shell Script Failed to Execute. Build Failed...'
					} else {
						echo 'Successful Execution Of Shell Script. Build Success...'
					}
				}

            }
        }
		
		stage('Deploy') {
            steps {

                echo 'Deploying...'

			}
        }
    }
 
    post{
        success{
			echo 'Success'
        }
    }
}