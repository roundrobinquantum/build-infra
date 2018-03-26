package main

import (
	"log"
	"net/url"
	"os"
	"strings"

	"github.com/sclevine/agouti"
)

func main() {
	os.Setenv("webdriver.chrome.driver", "/usr/local/bin/chromedriver")

	gitlabURL := os.Getenv("GITLAB_URL")

	if len(gitlabURL) <= 0 {
		log.Fatal("GITLAB_URL is empty")
		return
	}

	gitlabRootPassword := os.Getenv("GITLAB_ROOT_PASSWORD")

	if len(gitlabRootPassword) <= 0 {
		log.Fatal("GITLAB_ROOT_PASSWORD is empty")
		return
	}

	log.Println("Root Passwd is : ", gitlabRootPassword)

	chromeCapabilities := agouti.NewCapabilities().Browser("chrome").Platform("linux")

	page, err := agouti.NewPage("http://chrome:5556/wd/hub", agouti.Desired(chromeCapabilities))

	if err != nil {
		log.Fatal("Failed to open page:", err)
	}

	if err := page.Navigate(gitlabURL); err != nil {
		log.Fatal("Failed to navigate:", err)
	}

	signinURL, err := page.URL()

	if err != nil {
		log.Fatal("Failed to get page URL:", err)
	}

	u, _ := url.Parse(signinURL)

	if u.Path != "/users/password/edit" && strings.HasPrefix(u.RawQuery, "reset_password_token") {
		log.Fatal("Expected Sign-in URL path to start with /users/password/edit?reset_password_token= but got ", signinURL)
	}

	if err := page.FindByID("user_password").Fill(gitlabRootPassword); err != nil {
		log.Fatal("Failed to get ‘New Password’ input field:", err)
	}

	if err := page.FindByID("user_password_confirmation").Fill(gitlabRootPassword); err != nil {
		log.Fatal("Failed to get ‘Confirm New Password’ input field:", err)
	}

	if err := page.FindByName("commit").Submit(); err != nil {
		log.Fatal("Failed to get ‘Submit’ button:", err)
	}

	if err := page.Destroy(); err != nil {
		log.Fatal("Failed to destroy page:", err)
	}
}
