function (    
    is_offline="false",
    private_registry="172.22.6.2:5000",    
    custom_domain_name="tmaxcloud.org",    
    tmax_client_secret="tmax_client_secret",
    hyperauth_url="172.23.4.105",
    hyperauth_realm="tmax",
    console_subdomain="console",    
    gatekeeper_log_level="info",    
    gatekeeper_version="v1.0.2"
)

local target_registry = if is_offline == "false" then "" else private_registry + "/";
[
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "labels": {
            "kustomize.component": "profiles"
            },
            "name": "profiles-deployment",
            "namespace": "kubeflow"
        },
        "spec": {
            "replicas": 1,
            "selector": {
            "matchLabels": {
                "kustomize.component": "profiles"
            }
            },
            "template": {
            "metadata": {
                "annotations": {
                "sidecar.istio.io/inject": "true"
                },
                "labels": {
                "kustomize.component": "profiles"
                }
            },
            "spec": {
                "containers": [
                {
                    "command": [
                    "/access-management",
                    "-cluster-admin",
                    "$(ADMIN)",
                    "-userid-header",
                    "$(USERID_HEADER)",
                    "-userid-prefix",
                    "$(USERID_PREFIX)"
                    ],
                    "envFrom": [
                    {
                        "configMapRef": {
                        "name": "profiles-config-46c7tgh6fd"
                        }
                    }
                    ],
                    "image": std.join("", [target_registry, "docker.io/kubeflownotebookswg/kfam:v1.6.1"]),
                    "imagePullPolicy": "Always",
                    "livenessProbe": {
                    "httpGet": {
                        "path": "/metrics",
                        "port": 8081
                    },
                    "initialDelaySeconds": 30,
                    "periodSeconds": 30
                    },
                    "name": "kfam",
                    "resources": {
                    "limits": {
                        "cpu": "1",
                        "memory": "2.5Gi"
                    },
                    "requests": {
                        "cpu": "20m",
                        "memory": "250Mi"
                    }
                    },
                    "ports": [
                    {
                        "containerPort": 8081,
                        "name": "kfam-http",
                        "protocol": "TCP"
                    }
                    ]
                },
                {
                    "command": [
                    "/manager",
                    "-userid-header",
                    "$(USERID_HEADER)",
                    "-userid-prefix",
                    "$(USERID_PREFIX)",
                    "-workload-identity",
                    "$(WORKLOAD_IDENTITY)"
                    ],
                    "envFrom": [
                    {
                        "configMapRef": {
                        "name": "profiles-config-46c7tgh6fd"
                        }
                    }
                    ],
                    "image": std.join("", [target_registry, "docker.io/kubeflownotebookswg/profile-controller:v1.6.1"]),
                    "imagePullPolicy": "Always",
                    "livenessProbe": {
                    "httpGet": {
                        "path": "/healthz",
                        "port": 9876
                    },
                    "initialDelaySeconds": 15,
                    "periodSeconds": 20
                    },
                    "name": "manager",
                    "ports": [
                    {
                        "containerPort": 9876
                    }
                    ],
                    "readinessProbe": {
                    "httpGet": {
                        "path": "/readyz",
                        "port": 9876
                    },
                    "initialDelaySeconds": 5,
                    "periodSeconds": 10
                    },
                    "resources": {
                    "limits": {
                        "cpu": "1",
                        "memory": "2.5Gi"
                    },
                    "requests": {
                        "cpu": "20m",
                        "memory": "250Mi"
                    }
                    },
                    "volumeMounts": [
                    {
                        "mountPath": "/etc/profile-controller",
                        "name": "namespace-labels",
                        "readOnly": true
                    },                    
                    ]
                }
                ],
                "serviceAccountName": "profiles-controller-service-account",
                "volumes": [                
                {
                    "configMap": {
                    "name": "namespace-labels-data-4df5t8mdgf"
                    },
                    "name": "namespace-labels"
                }
                ]
            }
            }
        }
    }
]    