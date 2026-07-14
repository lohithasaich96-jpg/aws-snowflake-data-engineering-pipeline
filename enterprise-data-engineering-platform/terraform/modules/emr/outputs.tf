output "cluster_id" {
  description = "EMR cluster ID"
  value       = aws_emr_cluster.this.id
}

output "master_public_dns" {
  description = "Public DNS of the master node"
  value       = aws_emr_cluster.this.master_public_dns
}
