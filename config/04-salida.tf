output "vms_kubernetes_IPs_PUBLICA" { value = module.vms_kubernetes[*].la_ip_publica }
output "vms_kubernetes_IPs_PRIVADA" { value = module.vms_kubernetes[*].la_ip_privada }

# output "vms_kworkers_IPs_PUBLICA" { value = module.vms_kworkers[*].la_ip_publica }
# output "vms_kworkers_IPs_PRIVADA" { value = module.vms_kworkers[*].la_ip_privada }
