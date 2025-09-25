# Get current TGs
ALB_NAME="notes-app-alb"
BLUE_TARGET_GROUP_NAME="frontend-blue-tg"
GREEN_TARGET_GROUP_NAME="frontend-green-tg"

ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names "${ALB_NAME}" \
  --query "LoadBalancers[0].LoadBalancerArn" \
  --output text)
echo "ALB_ARN: ${ALB_ARN}"

BLUE_TG_ARN=$(aws elbv2 describe-target-groups \
  --names "${BLUE_TARGET_GROUP_NAME}" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)
echo "BLUE_TG_ARN: ${BLUE_TG_ARN}"

GREEN_TG_ARN=$(aws elbv2 describe-target-groups \
  --names "${GREEN_TARGET_GROUP_NAME}" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)
echo "GREEN_TG_ARN: ${GREEN_TG_ARN}"

LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn "${ALB_ARN}" \
  --query "Listeners[?Port==\`80\`].ListenerArn" \
  --output text)
echo "LISTENER_ARN: ${LISTENER_ARN}"

# Determine which TG is currently attached to the prod listener rule
CURRENT_PROD_RULE_TG_ARN=$(aws elbv2 describe-rules \
  --listener-arn "${LISTENER_ARN}" \
  --query "Rules[?Priority=='100'].Actions[0].TargetGroupArn | [0]" \
  --output text)

echo "Current prod target group is -> ${CURRENT_PROD_RULE_TG_ARN}"

if [ "${CURRENT_PROD_RULE_TG_ARN}" == "${BLUE_TG_ARN}" ]; then
  PREVIEW_TG=${GREEN_TG_ARN}
else
  PREVIEW_TG=${BLUE_TG_ARN}
fi
echo "PREVIEW_TG: ${PREVIEW_TG}"

PREVIEW_LISTENER_RULE_ARN=$(aws elbv2 describe-rules \
--listener-arn "${LISTENER_ARN}" \
--query "Rules[?Priority=='101'].RuleArn" \
--output text)
echo "PREVIEW_LISTENER_RULE_ARN: ${PREVIEW_LISTENER_RULE_ARN}"

echo "Update preview listener rule target group to -> ${PREVIEW_TG}"
# aws elbv2 modify-rule \
# --rule-arn ${PREVIEW_LISTENER_RULE_ARN} \
# --actions Type=forward,TargetGroupArn="${PREVIEW_TG}"
