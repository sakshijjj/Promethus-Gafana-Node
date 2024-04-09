resource "aws_instance" "monitoring_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  security_groups        = [aws_security_group.monitoring_sg.name]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              apt-get update && apt-get upgrade -y
              
              # Install Prometheus
              cd /tmp
              wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
              tar xvfz prometheus-*.tar.gz
              cd prometheus-2.26.0.linux-amd64/
              cp prometheus /usr/local/bin/
              cp promtool /usr/local/bin/
              mkdir -p /etc/prometheus
              cp -r consoles /etc/prometheus
              cp -r console_libraries /etc/prometheus
              cp prometheus.yml /etc/prometheus/prometheus.yml
              useradd --no-create-home --shell /bin/false prometheus
              chown -R prometheus:prometheus /etc/prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
              touch /etc/systemd/system/prometheus.service
              echo '[Unit]
              Description=Prometheus
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=prometheus
              Group=prometheus
              Type=simple
              ExecStart=/usr/local/bin/prometheus \
              --config.file /etc/prometheus/prometheus.yml \
              --storage.tsdb.path /var/lib/prometheus/ \
              --web.console.templates=/etc/prometheus/consoles \
              --web.console.libraries=/etc/prometheus/console_libraries

              [Install]
              WantedBy=multi-user.target' > /etc/systemd/system/prometheus.service
              systemctl daemon-reload
              systemctl start prometheus
              systemctl enable prometheus
              
              # Install Node Exporter
              wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
              tar xvfz node_exporter-*.tar.gz
              cd node_exporter-1.1.2.linux-amd64/
              cp node_exporter /usr/local/bin
              useradd --no-create-home --shell /bin/false node_exporter
              chown node_exporter:node_exporter /usr/local/bin/node_exporter
              touch /etc/systemd/system/node_exporter.service
              echo '[Unit]
              Description=Node Exporter
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=node_exporter
              Group=node_exporter
              Type=simple
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=multi-user.target' > /etc/systemd/system/node_exporter.service
              systemctl daemon-reload
              systemctl start node_exporter
              systemctl enable node_exporter
              
              # Install Grafana
              apt-get install -y software-properties-common
              add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
              wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
              apt-get update
              apt-get install grafana -y
              systemctl start grafana-server
              systemctl enable grafana-server
              EOF

  tags = {
    Name = "MonitoringInstance"
  }
}
