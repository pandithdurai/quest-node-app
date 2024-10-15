resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = "quest-node-app"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "quest-node-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "quest-node-app"
        }
      }

      spec {
        container {
          image = "us-central1-docker.pkg.dev/quest-demo-438215/rearc-quest/rearc-quest-node-app:latest"
          name  = "quest-node-app"
          
        env {
             name = "SECRET_WORD"
             value_from {
                secret_key_ref {
                  name = kubectl_manifest.secret.name
                  key  = "secret_word"
              }
           }
       }
         

          port {
            container_port = 3000
            name           = "node-app-svc"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }       

        }

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "default" {
  metadata {
    name = "quest-node-app-loadbalancer"
    annotations = {
      "cloud.google.com/neg" = "ingress" 
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
    }

    ip_family_policy = "RequireDualStack"

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.default.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "NodePort"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.default]

  destroy_duration = "180s"
}

resource "kubectl_manifest" "ingress" {
    yaml_body = file("${path.module}/ingress.yaml")
}

resource "kubectl_manifest" "secret" {
    yaml_body = file("${path.module}/secret.yaml")
}