#!/bin/bash
set -e

STACK_NAME="sagemaker-studio"

deploy() {
    echo "=== Deploying SageMaker Studio ==="
    rain deploy sagemaker-studio.yaml $STACK_NAME -y

    echo ""
    echo "=== Deployment Complete ==="
    echo ""
    outputs
}

outputs() {
    echo "=== Stack Outputs ==="
    rain ls $STACK_NAME -o 2>/dev/null || echo "(stack not deployed)"

    echo ""
    echo "=== Quick Start ==="
    echo "1. Go to AWS Console > SageMaker > Studio"
    echo "2. Select domain 'workshop-studio'"
    echo "3. Select user 'workshop-user'"
    echo "4. Click 'Open Studio'"
}

status() {
    aws cloudformation describe-stacks --stack-name $STACK_NAME \
        --query "Stacks[0].StackStatus" --output text 2>/dev/null || echo "NOT_DEPLOYED"
}

delete() {
    echo "=== Deleting SageMaker Studio ==="

    # Get domain ID
    DOMAIN_ID=$(aws cloudformation describe-stacks --stack-name $STACK_NAME \
        --query "Stacks[0].Outputs[?OutputKey=='DomainId'].OutputValue" \
        --output text 2>/dev/null || echo "")

    if [ -n "$DOMAIN_ID" ] && [ "$DOMAIN_ID" != "None" ]; then
        echo "Deleting apps for user profile..."
        # List and delete any running apps
        aws sagemaker list-apps --domain-id "$DOMAIN_ID" --user-profile-name workshop-user \
            --query "Apps[?Status=='InService'].{App:AppName,Type:AppType}" --output text 2>/dev/null | \
        while read -r APP_NAME APP_TYPE; do
            if [ -n "$APP_NAME" ]; then
                echo "  Deleting app: $APP_NAME ($APP_TYPE)"
                aws sagemaker delete-app --domain-id "$DOMAIN_ID" \
                    --user-profile-name workshop-user \
                    --app-name "$APP_NAME" \
                    --app-type "$APP_TYPE" 2>/dev/null || true
            fi
        done

        echo "Waiting for apps to delete..."
        sleep 30
    fi

    echo "Deleting CloudFormation stack..."
    rain rm $STACK_NAME -y 2>/dev/null || true

    echo "=== Deletion Complete ==="
}

case "$1" in
    deploy)
        deploy
        ;;
    outputs)
        outputs
        ;;
    status)
        status
        ;;
    delete)
        delete
        ;;
    *)
        echo "Usage: $0 {deploy|outputs|status|delete}"
        echo ""
        echo "Commands:"
        echo "  deploy   Deploy SageMaker Studio"
        echo "  outputs  Show stack outputs"
        echo "  status   Show stack status"
        echo "  delete   Delete everything"
        exit 1
        ;;
esac
