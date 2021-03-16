resource "aws_iam_role" "codepipeline_role" {
  count = var.codepipeline_role_arn == "" ? 1 : 0

  name               = "${var.function_name}-pipeline-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline[count.index].json
  tags               = var.tags
}

data "aws_iam_policy_document" "codepipeline" {
  count = var.codepipeline_role_arn == "" ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "codepipeline" {
  count = var.codepipeline_role_arn == "" ? 1 : 0

  name = "${var.function_name}-pipeline-${data.aws_region.current.name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:DescribeImages",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_repository_name}"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          module.s3_bucket.this_s3_bucket_arn,
          "${module.s3_bucket.this_s3_bucket_arn}/*"
        ]
      },
      {
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Effect   = "Allow"
        Resource = aws_codebuild_project.this.arn
      }
    ]
  })
  //  policy = data.aws_iam_policy_document.codepipeline_permissions[count.index].json
}

resource "aws_iam_role_policy_attachment" "codepipepline_extra" {
  count = var.codepipeline_role_arn == "" ? 1 : 0

  role       = aws_iam_role.codepipeline_role[count.index].name
  policy_arn = aws_iam_policy.codepipeline[count.index].arn
}

//data "aws_iam_policy_document" "codepipeline_permissions" {
//  count = var.codepipeline_role_arn == "" ? 1 : 0
//
//  statement {
//    actions = ["ecr:DescribeImages"]
//
//    resources = [
//      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_repository_name}"
//    ]
//  }
//
//  statement {
//    actions = [
//      "s3:GetObject",
//      "s3:ListBucket",
//      "s3:PutObject"
//    ]
//
//    resources = [
//      module.s3_bucket.this_s3_bucket_arn,
//      "${module.s3_bucket.this_s3_bucket_arn}/*"
//    ]
//  }
//
//  statement {
//    actions = [
//      "codebuild:StartBuild",
//      "codebuild:BatchGetBuilds"
//    ]
//
//    resources = [aws_codebuild_project.this.arn]
//  }
//}
