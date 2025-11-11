pipeline {
    agent any

    environment {
        AWS_CREDS_ID = 'aws-credentials'
        AWS_KEY_ID   = 'aws-ssh-key'
    }

    stages {
        stage('1. Build Infrastructure (Terraform)') {
            steps {
                // Use the AWS_CREDS_ID to inject AWS keys
                withCredentials([aws(credentialsId: AWS_CREDS_ID, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('2. Create Ansible Inventory') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: AWS_KEY_ID, keyFileVariable: 'AWS_KEY_FILE')]) {
                // Get the IP from Terraform's output
                // Create the 'inventory' file automatically
                sh '''
                    IP=$(terraform output -raw server_public_ip)
                    echo "[app_server]" > inventory
                    echo "$IP ansible_user=ubuntu ansible_ssh_private_key_file=${AWS_KEY_FILE}" >> inventory
                '''
            }
        }

        stage('3. Configure & Deploy (Ansible)') {
            steps {
                // Use the AWS_KEY_ID to inject the .pem file
                withCredentials([sshUserPrivateKey(credentialsId: AWS_KEY_ID, keyFileVariable: 'AWS_KEY_FILE')]) {
                    // Wait 60s for the server to be ready for SSH
                    sh 'sleep 60'

                    sh 'ansible-playbook -i inventory playbook.yml --ssh-extra-args="-o StrictHostKeyChecking=no"'
                }
            }
        }
    }

    post {
        always {
            echo '--- RUNNING POST-BUILD CLEANUP (TERRAFORM DESTROY) ---'
            withCredentials([aws(credentialsId: AWS_CREDS_ID, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                // Add "|| true" to prevents the 'destroy' step from failing the entire
                // pipeline's "green" status if something goes wrong.
                sh 'terraform destroy -auto-approve || true'
            }
        }
    }
}
