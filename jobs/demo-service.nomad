job "demo-service" {
  region = "global"

  datacenters = ["dc1"]

  # Rolling updates
  update {
    stagger = "10s"
    max_parallel = 5
  }

  group "frontend" {
    count = 5

    task "fib" {
      driver = "docker"
      config {
        image = "shinmyung0/fib-app"
        port_map {
          http = 10011
        }
      }
      service {
        name = "${TASKGROUP}-fib"
        port = "http"
        check {
          type = "http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }
      env {
        DEMO_NAME = "autoscaling-demo"
      }
      resources {
        cpu = 100
        memory = 300
        network {
          mbits = 10
          port "http" {}
        }
      }
    }
  }

  group "backend" {
    count = 3

    # Define a task to run
		task "redis" {
			# Use Docker to run the task.
			driver = "docker"

			# Configure Docker driver with the image
			config {
				image = "redis:latest"
				port_map {
					db = 6379
				}
			}

			service {
				name = "${TASKGROUP}-redis"
				tags = ["global", "cache"]
				port = "db"
				check {
					name = "alive"
					type = "tcp"
					interval = "10s"
					timeout = "2s"
				}
			}

			resources {
				cpu = 500 # 500 Mhz
				memory = 256 # 256MB
				network {
					mbits = 10
					port "db" {
					}
				}
			}

		}
  }


}
