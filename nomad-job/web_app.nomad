job "web_app" {
  datacenters = ["dc1"]

  group "db" {
    network {
      mode = "bridge"
    }
    service {
      name = "redis"
      port = "6379"

      connect {
        sidecar_service {}
      }
    }
    task "db" {           # The task stanza specifices a task (unit of work) within a group
      driver = "docker"      # This task uses Docker, other examples: exec, LXC, QEMU
      config {
        image = "redis:4-alpine" # Docker image to download (uses public hub by default)
        args = [
          "redis-server", "--requirepass", "redispass"
         
        ]  
      }
    } 
  }  

  group "counter" {
    count = 2
    network {
      mode = "bridge"

      port "http" {
  
        to     = 5000
      }
    }

    service {
      name = "webapp-proxy"
      port = "http"
      connect {
        sidecar_service {
            proxy {
                upstreams {
                  destination_name = "redis"
                  local_bind_port = 6479
                }
            }
        }
      }
    }

    service {
      name = "webapp"
      port = "http"
      tags = ["urlprefix-/"]
      check {
        name     = "HTTP Health Check"
        type     = "http"
        port     = "http"
        path     = "/health"
        interval = "5s"
        timeout  = "2s"
      }
    }
    
    task "app" {
      driver = "docker"      
      config {
        image = "denov/webpage-counter:0.1.0" 
      }
    }
  }
}
