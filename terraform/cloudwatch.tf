# ==============================================================================
# CLOUDWATCH OBSERVABILITY: TELEMETRY DASHBOARD & METRIC ALARMS
# ==============================================================================

# Centralized Deployment & Infrastructure Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-delivery-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum", period = 60 }],
            [".", "HTTPCode_Target_2XX_Count", ".", ".", { stat = "Sum", period = 60 }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { stat = "Sum", period = 60, color = "#d62728" }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "ALB Request Volume & Health Status Codes"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Average", period = 60 }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "Deployment Latency (Response Time in Seconds)"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.main.name, "ClusterName", aws_ecs_cluster.main.name, { stat = "Average", period = 60 }],
            [".", "MemoryUtilization", ".", ".", ".", ".", { stat = "Average", period = 60 }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "ECS Fargate Task CPU & Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_lb_target_group.app.arn_suffix, "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Average", period = 60 }],
            [".", "UnHealthyHostCount", ".", ".", ".", ".", { stat = "Average", period = 60, color = "#d62728" }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "Healthy vs Unhealthy Target Replicas (Failover Tracking)"
        }
      }
    ]
  })
}

# Metric Alarm: ALB 5XX Target Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Triggers when application returns more than 5 5XX errors in 1 minute."

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}
