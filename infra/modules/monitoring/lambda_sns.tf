# infra/modules/monitoring/lambda_sns.tf

resource "aws_sns_topic" "alerts" {
  name = "${var.project}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

data "archive_file" "alertmgr_to_sns" {
  type        = "zip"
  output_path = "${path.module}/build/alertmgr_to_sns.zip"
  source {
    filename = "index.py"
    content  = <<-EOT
      import json, os, boto3
      sns = boto3.client("sns")
      TOPIC = os.environ["TOPIC_ARN"]

      def handler(event, _):
          body = json.loads(event.get("body") or "{}")
          for alert in body.get("alerts", []):
              sns.publish(
                  TopicArn=TOPIC,
                  Subject=f"[{alert['status'].upper()}] {alert['labels'].get('alertname', 'dkron')}",
                  Message=json.dumps(alert, indent=2),
              )
          return {"statusCode": 200, "body": "ok"}
    EOT
  }
}

resource "aws_lambda_function" "alertmgr_to_sns" {
  function_name    = "${var.project}-alertmgr-to-sns"
  runtime          = "python3.12"
  handler          = "index.handler"
  role             = aws_iam_role.lambda.arn
  filename         = data.archive_file.alertmgr_to_sns.output_path
  source_code_hash = data.archive_file.alertmgr_to_sns.output_base64sha256
  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}

resource "aws_lambda_function_url" "alertmgr_to_sns" {
  function_name      = aws_lambda_function.alertmgr_to_sns.function_name
  authorization_type = "NONE" # OK porque solo Alertmanager (dentro de la VPC) conoce la URL
}
