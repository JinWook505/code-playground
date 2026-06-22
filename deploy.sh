#!/bin/bash

# ================================================================
# CodePlayground - AWS Deployment Script
# ================================================================
# This script builds and deploys the CodePlayground application to AWS
# ================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGION="ap-northeast-2"
PROJECT_NAME="code-playground"

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if AWS CLI is configured
check_aws_config() {
    print_info "Checking AWS CLI configuration..."
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Run 'aws configure' first."
        exit 1
    fi

    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    print_success "AWS CLI configured for account: $ACCOUNT_ID"
}

# Check if required files exist
check_prerequisites() {
    print_info "Checking prerequisites..."

    if [ ! -f "deploy/terraform.tfvars" ]; then
        print_error "terraform.tfvars not found. Please configure deploy/terraform.tfvars first."
        exit 1
    fi

    # Check if user has updated the placeholder values
    if grep -q "YOUR_ACCOUNT_ID\|CHANGE_ME" deploy/terraform.tfvars; then
        print_warning "Please update placeholder values in deploy/terraform.tfvars:"
        grep -n "YOUR_ACCOUNT_ID\|CHANGE_ME" deploy/terraform.tfvars || true
        print_error "Update the configuration before proceeding."
        exit 1
    fi

    print_success "Prerequisites check passed"
}

# Build Docker images
build_images() {
    print_info "Building Docker images..."

    # Get ECR login
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

    # Build backend
    print_info "Building backend image..."
    docker build --platform linux/amd64 -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME-backend:latest ./apps/backend

    # Build frontend
    print_info "Building frontend image..."
    docker build --platform linux/amd64 -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME-frontend:latest ./apps/frontend

    print_success "Docker images built successfully"
}

# Push images to ECR
push_images() {
    print_info "Pushing images to ECR..."

    # Push backend
    docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME-backend:latest

    # Push frontend
    docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME-frontend:latest

    print_success "Images pushed to ECR"
}

# Deploy infrastructure
deploy_infrastructure() {
    print_info "Deploying infrastructure with Terraform..."

    cd deploy

    # Initialize Terraform
    terraform init

    # Plan deployment
    terraform plan

    # Apply changes
    terraform apply -auto-approve

    # Get outputs
    ALB_DNS=$(terraform output -raw alb_dns_name)

    cd ..

    print_success "Infrastructure deployed successfully"
    print_info "Application URL: http://$ALB_DNS"
}

# Main deployment process
main() {
    print_info "🚀 Starting CodePlayground deployment..."

    check_aws_config
    check_prerequisites
    deploy_infrastructure
    build_images
    push_images

    print_success "🎉 Deployment completed successfully!"
    print_info "Your application should be available in a few minutes."
}

# Help function
show_help() {
    echo "CodePlayground Deployment Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --build-only   Only build and push images (requires infrastructure to be deployed first)"
    echo "  --infra-only   Only deploy infrastructure"
    echo ""
    echo "Deployment order:"
    echo "1. Infrastructure deployment (creates ECR repositories)"
    echo "2. Docker image build and push"
    echo ""
    echo "Before running:"
    echo "1. Configure AWS CLI: aws configure"
    echo "2. Update deploy/terraform.tfvars with your settings"
    echo "3. Run: ./deploy.sh"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --build-only)
        print_info "Building and pushing images only..."
        print_warning "Note: This assumes infrastructure is already deployed (ECR repositories exist)"
        check_aws_config
        check_prerequisites
        build_images
        push_images
        print_success "Build completed!"
        exit 0
        ;;
    --infra-only)
        print_info "Deploying infrastructure only..."
        check_aws_config
        check_prerequisites
        deploy_infrastructure
        print_success "Infrastructure deployment completed!"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac