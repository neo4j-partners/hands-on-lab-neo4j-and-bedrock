#!/bin/bash
set -e

STACK_VPC="sagemaker-unified-studio-vpc"
STACK_DOMAIN="sagemaker-unified-studio-domain"
STACK_PROFILE="sagemaker-unified-studio-project-profile"

deploy_cfn() {
    echo "=== Deploying VPC ==="
    rain deploy sagemaker-unified-studio-vpc.yaml $STACK_VPC -y

    echo "=== Deploying Domain ==="
    rain deploy sagemaker-unified-studio-domain.yaml $STACK_DOMAIN -y

    echo "=== Getting Domain ID ==="
    DOMAIN_ID=$(aws cloudformation describe-stacks \
        --stack-name $STACK_DOMAIN \
        --query "Stacks[0].Outputs[?OutputKey=='DomainId'].OutputValue" \
        --output text)
    echo "Domain ID: $DOMAIN_ID"

    echo "=== Deploying Project Profile ==="
    rain deploy sagemaker-unified-studio-project-profile.yaml $STACK_PROFILE \
        --params DomainId=$DOMAIN_ID -y

    echo "=== CloudFormation Deployment Complete ==="
    echo ""
    echo "Next steps:"
    echo "  1. Go to Portal URL (run: ./deploy.sh outputs)"
    echo "  2. Create a project in SageMaker Unified Studio"
    echo "  3. Run: ./deploy.sh inference"
}

deploy_all() {
    deploy_cfn
    echo ""
    echo "NOTE: To set up inference profiles, first create a project in"
    echo "SageMaker Unified Studio, then run:"
    echo "  ./deploy.sh inference"
}

inference() {
    echo "=== Setting Up Inference Profiles ==="
    ./setup-inference-profiles.sh "$@"
}

outputs() {
    echo "=== VPC Outputs ==="
    rain ls $STACK_VPC -o 2>/dev/null || echo "(stack not deployed)"

    echo ""
    echo "=== Domain Outputs ==="
    rain ls $STACK_DOMAIN -o 2>/dev/null || echo "(stack not deployed)"

    echo ""
    echo "=== Project Profile Outputs ==="
    rain ls $STACK_PROFILE -o 2>/dev/null || echo "(stack not deployed)"

    echo ""
    echo "=== Inference Profiles ==="
    ./setup-inference-profiles.sh --list 2>/dev/null || echo "(none created)"
}

status() {
    echo "=== CloudFormation Stack Status ==="
    printf "%-40s %s\n" "Stack" "Status"
    printf "%-40s %s\n" "-----" "------"

    for stack in $STACK_VPC $STACK_DOMAIN $STACK_PROFILE; do
        status=$(aws cloudformation describe-stacks --stack-name "$stack" \
            --query "Stacks[0].StackStatus" --output text 2>/dev/null || echo "NOT_DEPLOYED")
        printf "%-40s %s\n" "$stack" "$status"
    done

    echo ""
    echo "=== Inference Profiles ==="
    count=$(aws bedrock list-application-inference-profiles \
        --query "length(ApplicationInferenceProfileSummaries[?contains(InferenceProfileName, 'workshop')])" \
        --output text 2>/dev/null || echo "0")
    echo "Workshop profiles: $count"
}

delete_cfn() {
    echo "=== Deleting Project Profile ==="
    rain rm $STACK_PROFILE -y 2>/dev/null || true

    echo "=== Deleting Domain ==="
    rain rm $STACK_DOMAIN -y 2>/dev/null || true

    echo "=== Deleting VPC ==="
    rain rm $STACK_VPC -y 2>/dev/null || true

    echo "=== CloudFormation Deletion Complete ==="
}

delete_all() {
    echo "=== Deleting Inference Profiles ==="
    ./setup-inference-profiles.sh --delete-all 2>/dev/null || true

    delete_cfn
}

case "$1" in
    cfn)
        deploy_cfn
        ;;
    deploy)
        deploy_all
        ;;
    inference)
        shift
        inference "$@"
        ;;
    outputs)
        outputs
        ;;
    status)
        status
        ;;
    delete-cfn)
        delete_cfn
        ;;
    delete)
        delete_all
        ;;
    *)
        echo "Usage: $0 {cfn|deploy|inference|status|outputs|delete-cfn|delete}"
        echo ""
        echo "Commands:"
        echo "  cfn        Deploy CloudFormation only (VPC, Domain, Project Profile)"
        echo "  deploy     Deploy everything (same as cfn, with reminder for inference)"
        echo "  inference  Set up Bedrock inference profiles (run after creating a project)"
        echo "  status     Show stack and inference profile status"
        echo "  outputs    Show all stack outputs and inference profiles"
        echo "  delete-cfn Delete CloudFormation stacks only"
        echo "  delete     Delete everything including inference profiles"
        exit 1
        ;;
esac
