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
						echo 'Yes'
					}else {
						echo 'No'
					}	
						
				}
				
            }
        }
		
		stage('Test') {
            steps {

                echo 'Testing...'
				
				
				script {
					def failure = powershell label: '', returnStatus: true, script: 'Get-WmiObject Win32_OperatingSystem '
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