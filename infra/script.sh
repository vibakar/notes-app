# Get current TGs
BLUE_TG_ARN="arn:aws:elasticloadbalancing:...:targetgroup/frontend_blue_tg/..."
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names notes-app-alb \
  --query "LoadBalancers[0].LoadBalancerArn" \
  --output text)

BLUE_TG_ARN=$(aws elbv2 describe-target-groups \
  --names frontend-blue-tg \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

GREEN_TG_ARN=$(aws elbv2 describe-target-groups \
  --names frontend-green-tg \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

PROD_LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn arn:aws:elasticloadbalancing:eu-west-2:648378716943:loadbalancer/app/notes-app-alb/fe3e3152cd14b3ac \
  --query "Listeners[?Port==\`80\`].ListenerArn" \
  --output text)

TEST_LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn arn:aws:elasticloadbalancing:eu-west-2:648378716943:loadbalancer/app/notes-app-alb/fe3e3152cd14b3ac \
  --query "Listeners[?Port==\`9000\`].ListenerArn" \
  --output text)

# Determine which TG is currently attached to the prod listener (port 80)
CURRENT_PROD_TG=$(aws elbv2 describe-listeners \
  --listener-arn $PROD_LISTENER_ARN \
  --query 'Listeners[0].DefaultActions[0].TargetGroupArn' \
  --output text)

echo "Current prod target group is -> ${CURRENT_PROD_TG}"

# Find the "other" (previous) TG
if [ "$CURRENT_PROD_TG" == "$BLUE_TG_ARN" ]; then
  PREVIOUS_TG=$GREEN_TG_ARN
else
  PREVIOUS_TG=$BLUE_TG_ARN
fi

echo "Test listener target group is going to be -> ${PREVIOUS_TG}"
# Update test listener (port 9000) to point to previous TG
aws elbv2 modify-listener \
  --listener-arn $TEST_LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$PREVIOUS_TG
