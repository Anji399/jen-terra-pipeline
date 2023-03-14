resource "null_resource" "docker_deploy" {
   provisioner "local-exec" {
      command = <<EOH
           echo "${aws_instance.web-1.public_ip}"
                 > publicip.txt
           cat publicip.txt
      EOH
   }
}