import React, { Component, Fragment } from 'react';
import AuthService from '../AuthService'
import Logo from '../ActionBlocks/Layout/Logo'
import './Login.css'
import { Router } from '@reach/router';
import AuthenticationContext from './AuthenticationContext';
import { navigate } from '../../node_modules/@reach/router/lib/history';

class Login extends Component {

  state = { sent: false, processing: false }

  handleLogin = (uri,e) => {
    console.log(uri)
    console.log({handle1: this.props})
    e.preventDefault();
    // let that = this;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;
    new AuthService().login(email, password, uri == '/signin')
      .then((response) => {
        console.log('after login', response)
        this.props.updateCurrentUser(response);
      })
      .catch((error) => {
        console.log(error)
      })
  }

  handleResetPassword = (e) => {
    this.setState({ processing: true })
    e.preventDefault();
    const email = document.getElementById("email").value;
    new AuthService().resetPassword(email)
      .then((response) => {
        this.setState({sent: true, processing: false});
      })
      .catch((error) => {
        console.log(error)
        this.setState({ processing: false })
      })

  }

  handleNewPassword = (e, token) => {
    this.setState({ processing: true })
    e.preventDefault();
    const pass = document.getElementById("password").value;
    const confirmpass = document.getElementById("confirmpassword").value;
    new AuthService().newPassword(pass, confirmpass, token)
      .then((response) => {
        this.setState({sent: true, processing: false});
        this.props.navigate('/signin')
      })
      .catch((error) => {
        console.log(error)
        this.setState({ processing: false })
      })
  }

  render() {
    // console.log({render: this.props})
    return (
      <div class='Login container'>
        {/* <div class={`logo${this.state.processing ? '-animated' : ''}`}><Logo color='white' height='200px' width="200px" /></div> */}
        <div class='form'>
        <Router>
          <LoginForm onSubmit={this.handleLogin} path='/signin' default />
          <ForgotForm onSubmit={this.handleResetPassword} sent={this.state.sent} processing={this.state.processing} path='/signin/forgot-password'/>
          {/* <RegisterForm path='/signin/register'/> */}
          <NewPasswordForm onSubmit={this.handleNewPassword} sent={this.state.sent} path='/signin/new_password/:token'/>

        </Router>
        </div>
      </div>
    );
  };

};

const LoginForm = (props, {onSubmit}) => {
  console.log(props); return (
  <Fragment>
    <div class='header'>Login</div>
    <form>
      <label htmlFor="email">E-mail address</label>
      <input id="email" autoComplete='username'/>
      <label htmlFor="email">Password</label>
      <input id="password" type="password" autoComplete='current-password'/>
      <button onClick={(e) => props.onSubmit(props.uri, e)}>SIGN IN</button>
      <a href='/signin/forgot-password'>Forgot password?</a>
      {/* <a href='/signin/register'>New user? Register »</a> */}
    </form>
  </Fragment>
)}

const NewPasswordForm = ({sent, token, onSubmit}) => {
  if (!sent) {
    return (
      <Fragment>
        <div class='header'>Set new password</div>
        <form>
          <label htmlFor="password">Password</label>
          <input id="password" type="password" autoComplete='password'/>
          <label htmlFor="confirmpassword">Confirm Password</label>
          <input id="confirmpassword" type="password" autoComplete='confirm-password'/>
          <button onClick={(e) => onSubmit(e, token)}>CHANGE PASSWORD</button>
        </form>
      </Fragment>
    )
  } else {
    return (
      <Fragment>
        <div class='header'>Password reset</div>
        <div style={{marginTop:'1em', marginBottom: '2em'}}>Your password has been reset. You can now login with your new password.</div>
        <a href="/signin">Back to login</a>
      </Fragment>
    )
  }
}

const ForgotForm = ({onSubmit, sent, processing}) => {
  if (!sent) { 
    return (
      <Fragment>
        { processing && <div class="test" /> }
        <div class='header'>Forgotten password</div>
        <div style={{marginTop:'1em', marginBottom: '2em'}}>You will receive an e-mail with a URL to reset your password.</div>
        <form>
          <label htmlFor="email">E-mail address</label>
          <input id="email" placeholder="email" autoComplete='username'/>
          <button disabled={processing} onClick={onSubmit}>RESET PASSWORD</button>
          <a href="#" onClick={() => window.history.back()}>Back to login</a>
        </form>
      </Fragment>
    )
  } else {
    return (
      <Fragment>
        <div class='header'>Instructions sent</div>
        <div style={{marginTop:'1em', marginBottom: '2em'}}>An e-mail has been sent with a URL to reset your password.</div>
        <a href="#" onClick={() => window.history.back()}>Back to login</a>
      </Fragment>
    )
  }
}

const RegisterForm = ({onSubmit}) => (
  <Fragment>
    <div class='header'>Registration</div>
    <form>
      <label htmlFor="email">E-mail address</label>
      <input id="email" autoComplete='username'/>
      <label htmlFor="password">Password</label>
      <input id="password" type="password" autoComplete='password'/>
      <label htmlFor="confirmpassword">Confirm Password</label>
      <input id="confirmpassword" type="password" autoComplete='confirm-password'/>
      <button onClick={onSubmit}>REGISTER</button>
      <a href="#" onClick={() => window.history.back()}>Back to login</a>
    </form>
  </Fragment>
)

export default Login;
