import decode from "jwt-decode";
import { navigate } from "@reach/router";

/* eslint: ignore */

export default class AuthService {

  constructor() {
    this.fetch = this.fetch.bind(this);
    this.login = this.login.bind(this);
    this.fetchBlob = this.fetchBlob.bind(this);
    this.getProfile = this.getProfile.bind(this);
  }

  login(email, password, redirect = false) {
    // Get a token
    return this.fetch(`/login`, {
      method: "POST",
      body: JSON.stringify({
        user: {
          email,
          password
        }
      })
    }).then((res) => {
      console.log(res);
      this.setToken(res.headers.get(["Authorization"]).replace("Bearer ", ""));
      console.log('profile', this.getProfile())
      if (redirect) navigate('/');
    });
  }

  resetPassword(email) {
    return this.fetch(`/password`, {
      method: "POST",
      body: JSON.stringify({
        user: {
          email
        }
      })
    })
  }

  newPassword(pass, confirmpass, token) {
    return this.fetch(`/password.json`, {
      method: "PUT",
      body: JSON.stringify({
        user: {
          reset_password_token: token,
          password: pass,
          password_confirmation: confirmpass
        }
      })
    })
  }

  loggedIn() {
    // Checks if there is a saved token and it's still valid
    const token = this.getToken();
    return !!token && !this.isTokenExpired(token); // handwaiving here
  }

  isTokenExpired(token) {
    try {
      const decoded = decode(token);
      if (decoded.exp < Date.now() / 1000) {
        return true;
      } else return false;
    } catch (err) {
      return false;
    }
  }

  setToken(idToken) {
    // Saves user token to localStorage
    localStorage.setItem("id_token", idToken);
  }

  getToken() {
    // Retrieves the user token from localStorage
    return localStorage.getItem("id_token");
  }

  logout() {
    // Clear user token and profile data from localStorage
    return this.fetch(`/logout`, {
      method: "DELETE"
    }).then(r => localStorage.removeItem("id_token"));
  }

  getProfile() {
    return decode(this.getToken());
  }

  fetchBlob(url, options) {
    const headers = {
      Accept: "application/json",
      "Content-Type": "application/json"
    };

    if (this.loggedIn()) {
      headers["Authorization"] = "Bearer " + this.getToken();
    }

    return fetch(url, {
      headers,
      ...options
    })
      .then(this._checkStatus)
      .then(response => response.blob())
  }


  fetch(url, options) {
    // performs api calls sending the required authentication headers
    const headers = {
      Accept: "application/json",
      "Content-Type": "application/json"
    };

    if (this.loggedIn()) {
      headers["Authorization"] = "Bearer " + this.getToken();
    }

    return fetch(url, {
      headers,
      ...options
    })
      .then(this._checkStatus)
      .then((res) => {
        return res.json().then(json => ({
          headers: res.headers,
          status: res.status,
          body: json
        })).catch(r => r)
      });
  }

  /* eslint-disable class-methods-use-this */
  _checkStatus(response) {
    // raises an error in case response status is not a success
    if (response.status >= 200 && response.status < 300) {
      return response;
    } else {
      var error = new Error(response.statusText);
      error.response = response;
      throw error;
    }
  }

}
