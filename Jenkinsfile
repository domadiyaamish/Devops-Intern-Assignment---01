node{
    def buildnumber= BUILD_NUMBER
    stage("Git Clone"){
        git branch: 'main', url: 'https://github.com/domadiyaamish/Devops-Intern-Assignment---01.git'
    }
    stage("Build Docker Image"){
        sh "docker build -t amishdomadiyag/python-flask-app:${buildnumber} ."
    }
    stage("Push Docker Image"){
        
        withCredentials([string(credentialsId: 'Docker_Hub_Password', variable: 'Docker_Hub_Password')]) {
        sh "docker login -u amishdomadiyag -p ${Docker_Hub_Password}"
        
        }
        sh "docker push amishdomadiyag/python-flask-app:${buildnumber}"
    }
    stage("Deploy Docker Service In Docker Swarm Cluster"){
        sshagent(['Docker_Swarm_Manager']) {
            sh "ssh -o StrictHostKeyChecking=no ubuntu@43.204.37.14 sudo docker service rm python-flask-app || true"
            sh "ssh -o StrictHostKeyChecking=no ubuntu@43.204.37.14 sudo docker service create --name python-flask-app -p 3000:3000 --replicas 2 amishdomadiyag/python-flask-app:${buildnumber}"
        }
    }
}
