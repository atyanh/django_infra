data "aws_instance" "first_node" {
  filter {
    name   = "tag:eks:cluster-name"
    values = ["eks_cluster"]
  }
  filter {
    name   = "network-interface.subnet-id"
    values = [aws_subnet.public_subnet_for_eks_1.id]
  }

  depends_on = [
    aws_eks_node_group.worker-node-group
  ]
}
data "aws_instance" "second_node" {
  filter {
    name   = "tag:eks:cluster-name"
    values = ["eks_cluster"]
  }
  filter {
    name   = "network-interface.subnet-id"
    values = [aws_subnet.public_subnet_for_eks_2.id]
  }
  depends_on = [
    aws_eks_node_group.worker-node-group
  ]
}
resource "aws_lb_target_group" "tg_for_nodes" {
  name     = "tg-for-nodes"
  port     = var.app_port
  protocol = "TCP"
  vpc_id   = aws_vpc.my_vpc.id
  depends_on = [
    aws_eks_node_group.worker-node-group
  ]
}
resource "aws_lb_target_group_attachment" "nodes_attachement" {
  target_group_arn = aws_lb_target_group.tg_for_nodes.arn
  target_id        = data.aws_instance.first_node.id
  port             = var.app_port
}
resource "aws_lb_target_group_attachment" "nodes_attachement_2" {
  target_group_arn = aws_lb_target_group.tg_for_nodes.arn
  target_id        = data.aws_instance.second_node.id
  port             = var.app_port
}
resource "aws_lb" "eks-lb" {
  name                       = "eks-lb"
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = [aws_subnet.public_subnet_for_eks_1.id, aws_subnet.public_subnet_for_eks_2.id]
  enable_deletion_protection = false
  tags = {
    "kubernetes.io/service-name"          = "default/mario-service"
    "kubernetes.io/cluster/eks_cluster" = "owned"
  }
  depends_on = [
    aws_eks_node_group.worker-node-group
  ]
}
resource "aws_lb_listener" "http_listerner" {
  load_balancer_arn = aws_lb.eks-lb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.tg_for_nodes.id
    type             = "forward"
  }
}