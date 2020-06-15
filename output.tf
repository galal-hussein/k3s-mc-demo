output "k3s_demo_ips" {
  value = join(",", aws_instance.k3s-demo.*.public_ip)
}
