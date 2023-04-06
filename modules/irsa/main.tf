resource "kubernetes_namespace_v1" "irsa" {
  count = var.create_kubernetes_namespace && var.kubernetes_namespace != "kube-system" ? 1 : 0
  metadata {
    name = var.kubernetes_namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}

resource "kubernetes_service_account_v1" "irsa" {
  count = var.create_kubernetes_service_account ? 1 : 0
  metadata {
    name        = var.kubernetes_service_account
    namespace   = var.kubernetes_namespace
    annotations = var.irsa_iam_policies != null ? { "eks.amazonaws.com/role-arn" : aws_iam_role.irsa[0].arn } : null
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }

  automount_service_account_token = true
}

resource "aws_iam_role" "irsa" {
  count = var.irsa_iam_policies != null ? 1 : 0

  name        = format("%s-%s-%s", var.addon_context.eks_cluster_id, trim(var.kubernetes_service_account, "-*"), "irsa")
  description = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.addon_context.eks_oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${var.addon_context.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"
          }
        }
      }
    ]
  })
  path                  = var.addon_context.irsa_iam_role_path
  force_detach_policies = true
  permissions_boundary  = var.addon_context.irsa_iam_permissions_boundary

  tags = merge(
    {
      "Name"                         = format("%s-%s-%s", var.addon_context.eks_cluster_id, trim(var.kubernetes_service_account, "-*"), "irsa"),
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    },
    var.addon_context.tags
  )
}

resource "aws_iam_role_policy_attachment" "irsa" {
  count = var.irsa_iam_policies != null ? length(var.irsa_iam_policies) : 0

  policy_arn = var.irsa_iam_policies[count.index]
  role       = aws_iam_role.irsa[0].name
}
