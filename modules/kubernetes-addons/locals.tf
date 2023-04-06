locals {
  # Configuration for managing add-ons via ArgoCD.
  argocd_addon_config = {
    agones                    = var.enable_agones ? module.agones[0].argocd_gitops_config : null
    awsEfsCsiDriver           = var.enable_aws_efs_csi_driver ? module.aws_efs_csi_driver[0].argocd_gitops_config : null
    awsForFluentBit           = var.enable_aws_for_fluentbit ? module.aws_for_fluent_bit[0].argocd_gitops_config : null
    awsLoadBalancerController = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    certManager               = var.enable_cert_manager ? module.cert_manager[0].argocd_gitops_config : null
    clusterAutoscaler         = var.enable_cluster_autoscaler ? module.cluster_autoscaler[0].argocd_gitops_config : null
    ingressNginx              = var.enable_ingress_nginx ? module.ingress_nginx[0].argocd_gitops_config : null
    keda                      = var.enable_keda ? module.keda[0].argocd_gitops_config : null
    metricsServer             = var.enable_metrics_server ? module.metrics_server[0].argocd_gitops_config : null
    ondat                     = var.enable_ondat ? module.ondat[0].argocd_gitops_config : null
    prometheus                = var.enable_prometheus ? module.prometheus[0].argocd_gitops_config : null
    sparkOperator             = var.enable_spark_k8s_operator ? module.spark_k8s_operator[0].argocd_gitops_config : null
    tetrateIstio              = var.enable_tetrate_istio ? module.tetrate_istio[0].argocd_gitops_config : null
    traefik                   = var.enable_traefik ? module.traefik[0].argocd_gitops_config : null
    vault                     = var.enable_vault ? module.vault[0].argocd_gitops_config : null
    vpa                       = var.enable_vpa ? module.vpa[0].argocd_gitops_config : null
    yunikorn                  = var.enable_yunikorn ? module.yunikorn[0].argocd_gitops_config : null
    argoRollouts              = var.enable_argo_rollouts ? module.argo_rollouts[0].argocd_gitops_config : null
    karpenter                 = var.enable_karpenter ? module.karpenter[0].argocd_gitops_config : null
    kubernetesDashboard       = var.enable_kubernetes_dashboard ? module.kubernetes_dashboard[0].argocd_gitops_config : null
    awsCloudWatchMetrics      = var.enable_aws_cloudwatch_metrics ? module.aws_cloudwatch_metrics[0].argocd_gitops_config : null
  }

  eks_oidc_issuer_url = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.eks_cluster.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = var.eks_cluster_id
    eks_oidc_issuer_url            = local.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    tags                           = var.tags
    irsa_iam_role_path             = var.irsa_iam_role_path
    irsa_iam_permissions_boundary  = var.irsa_iam_permissions_boundary
  }

  # For addons that pull images from a region-specific ECR container registry by default
  # for more information see: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  amazon_container_image_registry_uris = tomap({
    af-south-1     = "877085696533.dkr.ecr.af-south-1.amazonaws.com/amazon",
    ap-east-1      = "800184023465.dkr.ecr.ap-east-1.amazonaws.com/amazon",
    ap-northeast-1 = "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com/amazon",
    ap-northeast-2 = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon",
    ap-northeast-3 = "602401143452.dkr.ecr.ap-northeast-3.amazonaws.com/amazon",
    ap-south-1     = "602401143452.dkr.ecr.ap-south-1.amazonaws.com/amazon",
    ap-southeast-1 = "602401143452.dkr.ecr.ap-southeast-1.amazonaws.com/amazon",
    ap-southeast-2 = "602401143452.dkr.ecr.ap-southeast-2.amazonaws.com/amazon",
    ca-central-1   = "602401143452.dkr.ecr.ca-central-1.amazonaws.com/amazon",
    cn-north-1     = "918309763551.dkr.ecr.cn-north-1.amazonaws.com.cn/amazon",
    cn-northwest-1 = "961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn/amazon",
    eu-central-1   = "602401143452.dkr.ecr.eu-central-1.amazonaws.com/amazon",
    eu-north-1     = "602401143452.dkr.ecr.eu-north-1.amazonaws.com/amazon",
    eu-south-1     = "590381155156.dkr.ecr.eu-south-1.amazonaws.com/amazon",
    eu-west-1      = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon",
    eu-west-2      = "602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon",
    eu-west-3      = "602401143452.dkr.ecr.eu-west-3.amazonaws.com/amazon",
    me-south-1     = "558608220178.dkr.ecr.me-south-1.amazonaws.com/amazon",
    sa-east-1      = "602401143452.dkr.ecr.sa-east-1.amazonaws.com/amazon",
    us-east-1      = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon",
    us-east-2      = "602401143452.dkr.ecr.us-east-2.amazonaws.com/amazon",
    us-gov-east-1  = "151742754352.dkr.ecr.us-gov-east-1.amazonaws.com/amazon",
    us-gov-west-1  = "013241004608.dkr.ecr.us-gov-west-1.amazonaws.com/amazon",
    us-west-1      = "602401143452.dkr.ecr.us-west-1.amazonaws.com/amazon",
    us-west-2      = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon"
  })
}
