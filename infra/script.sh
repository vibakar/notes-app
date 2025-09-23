# Get current TGs
BLUE_TG_ARN="arn:aws:elasticloadbalancing:...:targetgroup/frontend_blue_tg/..."
GREEN_TG_ARN="arn:aws:elasticloadbalancing:...:targetgroup/frontend_green_tg/..."
PROD_LISTENER_ARN=""
TEST_LISTENER_ARN=""

# Determine which TG is currently attached to the prod listener (port 80)
CURRENT_PROD_TG=$(aws elbv2 describe-listeners \
  --listener-arn $PROD_LISTENER_ARN \
  --query 'Listeners[0].DefaultActions[0].TargetGroupArn' \
  --output text)

# Find the "other" (previous) TG
if [ "$CURRENT_PROD_TG" == "$BLUE_TG_ARN" ]; then
  PREVIOUS_TG=$GREEN_TG_ARN
else
  PREVIOUS_TG=$BLUE_TG_ARN
fi

# Update test listener (port 9000) to point to previous TG
aws elbv2 modify-listener \
  --listener-arn $TEST_LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$PREVIOUS_TG
