import React, { Component } from 'react';
import Login from './Login.js';
import AuthenticationContext from "./AuthenticationContext.js";
import AuthService from '../AuthService'

class AuthenticationProvider extends Component {


  updateCurrentUser = () => {
    this.setState({ auth_data: { signed_in: new AuthService().loggedIn() }})
  }

  componentDidMount() {
    this.setState({ auth_data: { signed_in: new AuthService().loggedIn() }})
  }

  logout = () => {
    new AuthService().logout()
    this.setState({ auth_data: { signed_in: false }})
  }

  state = { auth_data: { signed_in: false, user: 'jeff'}, logout: this.logout };


  render() {
    if (this.state.auth_data && this.state.auth_data.signed_in) {
      return (
        <AuthenticationContext.Provider value={this.state}>
          {this.props.children}
        </AuthenticationContext.Provider>
      )
    }
    else {
      return <Login updateCurrentUser={this.updateCurrentUser}/>;
    }
  }
}

export default AuthenticationProvider;
