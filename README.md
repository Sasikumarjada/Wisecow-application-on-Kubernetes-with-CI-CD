# Wisecow-application-on-Kubernetes-with-CI-CD
# 🐄 Wisecow Kubernetes Deployment Project

[![CI/CD Pipeline](https://github.com/sasikumarjada/wisecow-k8s/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/yourusername/wisecow-k8s/actions/workflows/ci-cd.yaml)
[![Security Scan](https://github.com/sasikumarjada/wisecow-k8s/actions/workflows/security.yaml/badge.svg)](https://github.com/yourusername/wisecow-k8s/actions/workflows/security.yaml)

A complete containerized deployment of the Wisecow application on Kubernetes with automated CI/CD pipeline, TLS security, and production-ready configurations.

## 🎯 Project Overview

This project demonstrates the complete DevOps lifecycle for deploying a simple web application (Wisecow) that serves fortune quotes with cowsay formatting. The solution includes:

- **Containerization**: Docker container with security best practices
- **Kubernetes Deployment**: Production-ready K8s manifests with health checks
- **CI/CD Pipeline**: Automated build, test, security scan, and deployment
- **TLS Security**: HTTPS support with cert-manager integration
- **Monitoring**: Prometheus metrics and health endpoints
- **High Availability**: Multi-replica deployment with rolling updates

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│ Container Registry│
│                 │    │     CI/CD       │    │     (GHCR)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Users       │◀───│  Ingress + TLS  │◀───│  Kubernetes     │
│   (HTTPS)       │    │   (nginx)       │    │    Cluster      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
                                              ┌─────────────────┐
                                              │   Wisecow Pods  │
                                              │ (Load Balanced) │
                                              └─────────────────┘
```

## 📁 Project Structure

```
wisecow-k8s/
├── 📄 README.md                    # This file
├── 🐳 Dockerfile                   # Container image definition
├── 🔧 wisecow.sh                   # Main application script
│
├── 📁 k8s/                         # Kubernetes manifests
│   ├── deployment.yaml             # Application deployment
│   ├── service.yaml                # LoadBalancer service
│   ├── ingress-tls.yaml            # Ingress with TLS
│   └── cert-manager-setup.yaml     # TLS certificate management
│
├── 📁 .github/workflows/           # CI/CD pipeline
│   └── ci-cd.yaml                  # GitHub Actions workflow
│
├── 📁 scripts/                     # Deployment utilities
│   ├── deploy.sh                   # Main deployment script
│   └── generate-certs.sh           # TLS certificate generation
│
├── 📁 docs/                        # Documentation
│   ├── DEPLOYMENT.md               # Deployment guide
│   ├── MONITORING.md               # Monitoring setup
│   └── TROUBLESHOOTING.md          # Common issues
│
└── 📁 tests/                       # Test files
    ├── smoke-tests.sh              # Basic functionality tests
    └── load-tests.sh               # Performance tests
```

## 🚀 Quick Start

### Prerequisites

- **Kubernetes cluster** (Minikube, Kind, EKS, GKE, AKS, etc.)
- **kubectl** configured to access your cluster
- **Docker** for local builds (optional)
- **Git** for version control

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/wisecow-k8s.git
cd wisecow-k8s

# Make scripts executable
chmod +x scripts/*.sh
```

### 2. Local Development

```bash
# Build and test locally
docker build -t wisecow:local .
docker run -p 4499:4499 wisecow:local

# Visit http://localhost:4499
```

### 3. Deploy to Kubernetes

```bash
# Quick deployment with defaults
./scripts/deploy.sh

# Or with custom configuration
./scripts/deploy.sh \
  --namespace wisecow \
  --domain wisecow.example.com \
  --environment production
```

### 4. Access the Application

After deployment, the script will show you how to access the application:

```bash
# If LoadBalancer is available
curl http://<EXTERNAL-IP>

# Or use port-forwarding
kubectl port-forward service/wisecow-service 8080:80
curl http://localhost:8080
```

## 🔧 Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NAMESPACE` | `default` | Kubernetes namespace |
| `IMAGE_TAG` | `latest` | Docker image tag |
| `DOMAIN` | `wisecow.local` | Application domain |
| `ENVIRONMENT` | `development` | Deployment environment |

### Deployment Environments

#### Development
- Self-signed TLS certificates
- Relaxed security policies
- Debug logging enabled

#### Staging
- Let's Encrypt staging certificates
- Production-like configuration
- Automated testing

#### Production
- Let's Encrypt production certificates
- Security hardening
- Monitoring and alerting

## 🔐 Security Features

### Container Security
- ✅ Non-root user execution
- ✅ Read-only root filesystem where possible
- ✅ Security context constraints
- ✅ Resource limits and requests
- ✅ Health checks for reliability

### Network Security
- ✅ TLS/HTTPS encryption
- ✅ Network policies (optional)
- ✅ Ingress with SSL termination
- ✅ Rate limiting

### CI/CD Security
- ✅ Vulnerability scanning with Trivy
- ✅ SAST security checks
- ✅ Container image signing
- ✅ Secrets management

## 📊 Monitoring and Observability

### Health Checks
- **Liveness Probe**: `/health` endpoint
- **Readiness Probe**: Application ready check
- **Startup Probe**: Initial health verification

### Metrics
- **Prometheus Metrics**: Available at `/metrics`
- **Custom Metrics**: Request counts, response times
- **Kubernetes Metrics**: Pod, deployment, service metrics

### Logging
- **Structured Logging**: JSON format for easy parsing
- **Log Aggregation**: Compatible with ELK, Fluentd
- **Error Tracking**: Application and infrastructure errors

## 🔄 CI/CD Pipeline

The GitHub Actions workflow provides:

### Automated Testing
```yaml
jobs:
  test:
    - Syntax validation
    - Dependency checks  
    - Unit tests
    - Integration tests
```

### Build and Security
```yaml
  build-and-push:
    - Multi-arch container builds
    - Container registry push
    - Image vulnerability scanning
    - Security policy validation
```

### Deployment
```yaml
  deploy:
    - Staging deployment
    - Smoke tests
    - Production deployment
    - Rollback on failure
```

## 🛠️ Advanced Usage

### Custom Domain Setup

1. **Update DNS records** to point to your ingress IP
2. **Configure certificate issuer**:
```yaml
# Edit k8s/cert-manager-setup.yaml
spec:
  acme:
    email: your-email@domain.com
```
3. **Deploy with custom domain**:
```bash
./scripts/deploy.sh -d your-domain.com -e production
```

### Horizontal Pod Autoscaling

```bash
# Enable HPA
kubectl autoscale deployment wisecow-deployment \
  --cpu-percent=70 \
  --min=3 \
  --max=10 \
  --namespace=wisecow
```

### Monitoring Setup

```bash
# Install Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack

# Import Wisecow dashboard
kubectl apply -f monitoring/grafana-dashboard.yaml
```

## 🐛 Troubleshooting

### Common Issues

#### Pod Not Starting
```bash
# Check pod status
kubectl get pods -l app=wisecow
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check resource constraints
kubectl top pods
```

#### Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints wisecow-service
kubectl describe service wisecow-service

# Test internal connectivity
kubectl run debug --image=curlimages/curl -it --rm -- sh
curl http://wisecow-service/health
```

#### TLS Certificate Issues
```bash
# Check certificate status
kubectl get certificates
kubectl describe certificate wisecow-tls-cert

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

#### Image Pull Errors
```bash
# Check image pull secrets
kubectl get secrets
kubectl describe secret <image-pull-secret>

# Check registry permissions
docker login ghcr.io
```

### Performance Optimization

#### Resource Tuning
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"  
    cpu: "1000m"
```

#### Caching Setup
```yaml
# Add Redis for session storage
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:alpine
        ports:
        - containerPort: 6379
```

## 🧪 Testing

### Local Testing
```bash
# Unit tests
./scripts/test-app.sh

# Smoke tests
./scripts/smoke-tests.sh localhost:8080

# Load tests
./scripts/load-tests.sh localhost:8080 100 60
```

### Kubernetes Testing
```bash
# Deploy test environment
./scripts/deploy.sh -n wisecow-test -e development

# Run integration tests
kubectl run test --image=curlimages/curl --rm -it -- sh
curl -f http://wisecow-service.wisecow-test.svc.cluster.local/health
```

## 📚 Additional Resources

### Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Guide](https://docs.github.com/en/actions)
- [cert-manager Documentation](https://cert-manager.io/docs/)

### Related Projects
- [Original Wisecow Repository](https://github.com/nyrahul/wisecow)
- [Kubernetes Examples](https://github.com/kubernetes/examples)
- [Helm Charts](https://artifacthub.io/)

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines
- Follow the existing code style
- Add tests for new features
- Update documentation
- Ensure CI/CD pipeline passes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Original Wisecow**: Created by [nyrahul](https://github.com/nyrahul)
- **Fortune-mod**: Classic Unix fortune program
- **Cowsay**: ASCII art cow sayings
- **Kubernetes Community**: For excellent documentation and tools
- **GitHub Actions**: For powerful CI/CD capabilities

## 📞 Support

### Getting Help
- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Community support and questions
- **Documentation**: Check the docs/ directory for detailed guides

### Status Page
- **CI/CD Status**: [![Build Status](https://github.com/sasikumarjada/wisecow-k8s/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/sasikumarjada/wisecow-k8s/actions)
- **Security Status**: [![Security Scan](https://github.com/sasikumarjada/wisecow-k8s/actions/workflows/security.yaml/badge.svg)](https://github.com/sasikumarjada/wisecow-k8s/actions)

---

**Made with ❤️ for the DevOps community**

*This project demonstrates modern DevOps practices including containerization, Kubernetes deployment, CI/CD automation, security scanning, and production-ready configurations.*
