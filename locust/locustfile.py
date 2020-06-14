## This script for evaluate Rule base on user identity in traffic/routing management of Istio's feature.
## Found at https://istio.io/latest/docs/tasks/traffic-management/fault-injection/
## Please change $HOST, $USER and $PASSWD below according to the page.

from locust import HttpUser, between, task

class LoggedInUser(HttpUser):
    wait_time = between(3, 6)
    host = "$HOST"

    def login(self):
        self.client.post("/login", {
	    "username": "$USER",
	    "passwd": "$PASSWD",
	    "submit": "Sign in",
	})

    def on_start(self):
        self.login()

    @task
    def productpage(self):
        self.client.get("/productpage")