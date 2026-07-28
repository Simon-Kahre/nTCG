package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"os"
)

type TokenResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
	ExpiresIn   int    `json:"expires_in"`
	IDToken     string `json:"id_token"`
	Scope       string `json:"scope"`
}

var ssoAddress string
var ssoPort string
var gameAddress string
var gamePort string

var ssoURL string

var gameURL string

func main() {
	ssoAddress := os.Getenv("SSO_ADDRESS")
	ssoPort := os.Getenv("SSO_PORT")
	gameAddress := os.Getenv("GAME_ADDRESS")
	gamePort := os.Getenv("GAME_PORT")

	ssoURL := fmt.Sprintf("http://%s:%s", ssoAddress, ssoPort)

	gameURL := fmt.Sprintf("http://%s:%s", gameAddress, gamePort)

	http.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {

		params := url.Values{}
		params.Set("client_id", "client-id")
		params.Set("redirect_uri", gameURL + "/oidcc/callback")
		params.Set("response_type", "code")
		params.Set("scope", "openid")

		loginURL := ssoURL + "/authorize?" + params.Encode()

		http.Redirect(
			w,
			r,
			loginURL,
			http.StatusFound,
		)
	})

	http.HandleFunc("/oidcc/callback", func(w http.ResponseWriter, r *http.Request) {

		code := r.URL.Query().Get("code")

		if code == "" {
			http.Error(w, "missing authorization code", http.StatusBadRequest)
			return
		}

		data := url.Values{}
		data.Set("grant_type", "authorization_code")
		data.Set("client_id", "client-id")
		data.Set("client_secret", "client-secret")
		data.Set("code", code)
		data.Set("redirect_uri", gameURL + "/oidcc/callback")

		req, err := http.NewRequest(
			"POST",
			"http://host.docker.internal:" + ssoPort + "/oauth/token",
			strings.NewReader(data.Encode()),
		)

		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}

		req.Header.Set(
			"Content-Type",
			"application/x-www-form-urlencoded",
		)

		resp, err := http.DefaultClient.Do(req)

		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}

		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)

		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}

		var token TokenResponse

		err = json.Unmarshal(body, &token)

		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}

		claims, err := decodeIDToken(token.IDToken)

		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}

		userID, ok := claims["sub"].(string)

		if !ok {
			http.Error(w, "invalid sub claim", http.StatusInternalServerError)
			return
		}

		fmt.Println("Logged in user:", userID)

		http.SetCookie(w, &http.Cookie{
			Name:     "user",
			Value:    userID,
			Path:     "/",
			HttpOnly: true,

			// Required because Godot is on :8080 and API is on :4000
			SameSite: http.SameSiteLaxMode,

			// For local HTTP development.
			// Enable this in production with HTTPS.
			Secure: false,
		})

		//redirect := "http://localhost:8080"

		http.Redirect(
			w,
			r,
			gameURL,
			http.StatusFound,
		)
	})

	http.HandleFunc("/me", func(w http.ResponseWriter, r *http.Request) {

		enableCORS(w)

		// Handle browser preflight request
		if r.Method == http.MethodOptions {
			return
		}

		cookie, err := r.Cookie("user")

		if err != nil {
			http.Error(w, "not logged in", http.StatusUnauthorized)
			return
		}

		w.Header().Set(
			"Content-Type",
			"application/json",
		)

		json.NewEncoder(w).Encode(map[string]string{
			"user": cookie.Value,
		})
	})

	fmt.Println("Running on http://localhost:4000")
	http.ListenAndServe(":4000", nil)
}


func enableCORS(w http.ResponseWriter) {

	w.Header().Set(
		"Access-Control-Allow-Origin",
		gameURL,
	)

	w.Header().Set(
		"Access-Control-Allow-Credentials",
		"true",
	)

	w.Header().Set(
		"Access-Control-Allow-Headers",
		"Content-Type",
	)

	w.Header().Set(
		"Access-Control-Allow-Methods",
		"GET, OPTIONS",
	)
}


func decodeIDToken(idToken string) (map[string]interface{}, error) {

	parts := strings.Split(idToken, ".")

	if len(parts) != 3 {
		return nil, fmt.Errorf("invalid JWT format")
	}

	payload, err := base64.RawURLEncoding.DecodeString(parts[1])

	if err != nil {
		return nil, err
	}

	var claims map[string]interface{}

	err = json.Unmarshal(payload, &claims)

	if err != nil {
		return nil, err
	}

	return claims, nil
}