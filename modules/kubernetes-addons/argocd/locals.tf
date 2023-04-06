locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  # Admin Password
  set_sensitive = var.admin_password_secret_name != "" ? [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = data.aws_secretsmanager_secret_version.admin_password_version[0].secret_string
    }
  ] : []

  name      = "argo-cd"
  namespace = "argocd"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "3.33.3"
    namespace        = local.namespace
    timeout          = "1200"
    create_namespace = true
    values           = local.default_helm_values
    description      = "The ArgoCD Helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_argocd_application = {
    namespace          = local.helm_config["namespace"]
    target_revision    = "HEAD"
    destination        = "https://kubernetes.default.svc"
    project            = "default"
    values             = {}
    add_on_application = false
  }

  global_application_values = {
    region      = var.addon_context.aws_region_name
    account     = var.addon_context.aws_caller_identity_account_id
    clusterName = var.addon_context.eks_cluster_id
  }
}
