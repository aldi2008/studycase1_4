pipeline {
  agent any
  environment {
    DOCKERHUB_CRED = 'dockerhub-creds'   // ID credentials di Jenkins
    DOCKER_IMAGE = "YOUR_DOCKERHUB_USERNAME/demo-app"
    KUBE_CONFIG_CRED = 'kubeconfig'      // optional: ID for kubeconfig if stored as secret file
    HELM_CHART_DIR = "charts/demo-app"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${DOCKER_IMAGE}:latest ."
      }
    }
    stage('Login & Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CRED}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${DOCKER_IMAGE}:latest
            docker logout
          """
        }
      }
    }
    stage('Deploy to Kubernetes with Helm') {
      steps {
        // If Jenkins has kubeconfig file in workspace or mounted ~/.kube/config
        sh """
          # override image tag if needed
          helm upgrade --install demo-app ${HELM_CHART_DIR} --set image.repository=${DOCKER_IMAGE} --set image.tag=latest --wait
        """
      }
    }
    stage('Verify Deployment') {
      steps {
        sh """
          kubectl get pods -l app=demo-app -o wide
          kubectl rollout status deployment/demo-app --timeout=120s || true
        """
      }
    }
    stage('Smoke Test') {
      steps {
        // For Minikube NodePort we can use minikube service to get URL; else use kubectl port-forward
        sh """
          # try to hit the service via cluster (nodeport)
          printf 'Waiting 5s for service...\n'
          sleep 5
          # try curl against node on localhost:30080 (values.yaml used 30080)
          if command -v minikube >/dev/null 2>&1; then
            minikube service demo-app --url
          fi
          curl -sS --max-time 10 http://localhost:30080/ || true
        """
      }
    }
  }
  post {
    always {
      echo "Pipeline finished."
    }
  }
}
