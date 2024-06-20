data "aws_caller_identity" "account" {
}

data "aws_partition" "current" {
}

data "aws_iam_role" "this" {
  count = var.iam_role_devops == "" ? 0 : 1
  name  = var.iam_role_devops
}

data "aws_iam_group" "this" {
  count      = var.iam_group_devops == "" ? 0 : 1
  group_name = var.iam_group_devops
}

# Policy per AWS case # 7226574571
data "aws_iam_policy_document" "this" {
  statement {
    sid    = "EKSAdministrator"
    effect = "Allow"

    actions = [
      "eks:*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "KMSPerm"
    effect = "Allow"

    actions = [
      "kms:CreateGrant",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "IAMPassRoleToEKS"
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "eks.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "IAMEKSIRSA"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:TagPolicy",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreatePolicy",
      "iam:ListOpenIDConnectProviders",
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:TagRole",
      "iam:ListPolicyVersions",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:UntagRole",
      "iam:UntagPolicy",
      "iam:UntagOpenIDConnectProvider",
      "iam:DetachRolePolicy"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManagedPrefixLists"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:CreateSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DescribeManagedPrefixLists",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:GetManagedPrefixListEntries",
      "ec2:DescribeTags",
      "ec2:ModifySecurityGroupRules",
      "ec2:DescribeSecurityGroups",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DescribeSecurityGroupRules",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:DeleteSecurityGroup"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "this_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.account.account_id}:root","arn:aws:iam::${data.aws_caller_identity.account.account_id}:user/terraform"]
    }
  }
}

locals {
  role_name = "eks-provisioner"
}
