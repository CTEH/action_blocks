import React, { Component } from 'react';
import { Link } from "@reach/router";
import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'
import BlockConsumer from "../BlockConsumer.js";
import Logo from './Logo.js';

import AuthenticationConsumer from '../../Devise/AuthenticationConsumer'

import './BootstrapBar.css';
import AuthService from '../../AuthService';

class AppBar extends Component {

  renderWorkspaceLink = (ws) => {
    return (
      <li key={ws.key} className="nav-item active">
        <Link className="nav-link" to={`/${ws.key}`}>
          {ws.title}
        </Link>
      </li>
    )
  }

  render() {
    console.log(this.props)
    const block = this.props.block;
    const blocks = this.props.blocks;
    const workspaces = block.workspace_keys.map(key => blocks[key])
    return (
      <nav className="navbar navbar-expand Layout-BootstrapBar">
        <a className="brand" href="/">
          <Logo color='white' height='24px' width="24px" />
        </a>
        <form className="form-inline">
          <input className="form-control" type="search" placeholder="Search" aria-label="Search" />
        </form>

        <div className="navbarSupportedContent">
          <ul className="navbar-nav mr-auto">
            {
              workspaces.map(this.renderWorkspaceLink)
            }
          </ul>
        </div>
        <div style={{flex:1, textAlign:'right'}}>
        <Dropdown id="user-dropdown">
              <DropdownTrigger>
                Logged in &nbsp;
                <span className="fas fa-caret-down"></span>
              </DropdownTrigger>
              <DropdownContent>
                <ul>
                  {/* <li>
                    <a href="/profile">Profile</a>
                  </li>
                  <li>
                    <a href="/favorites">Favorites</a>
                  </li> */}
                  <li>
                    <a href="#" onClick={this.props.auth.logout}>Sign&nbsp;Out</a>
                  </li>
                </ul>
              </DropdownContent>
          </Dropdown>
        </div>
      </nav>
    );
  }

}

export default AuthenticationConsumer(BlockConsumer(AppBar));
