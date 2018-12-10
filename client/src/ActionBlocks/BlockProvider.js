import React, { Component } from 'react';
import BlockContext from "./BlockContext.js";
import AuthService from '../AuthService';
import './BlockProvider.css';

class BlockProvider extends Component {

  state = {};
  componentDidMount() {
    this._asyncRequest = new AuthService().fetch('/action_blocks/blocks.json')
      .then(res => this.setState({blocks: res.body}))
      .catch(error => console.log(error));
  }

  // componentWillUnmount() {
  //   // if (this._asyncRequest) {
  //   //   this._asyncRequest.cancel();
  //   // }
  // }

  renderApp() {
    // const block = this.props.block;
    return (
      <BlockContext.Provider value={this.state.blocks}>
        {this.props.children}
      </BlockContext.Provider>
    );
  }

  renderError = (error) => {
    return (
      <div className="BlockProvider_error">
        <div className="builder">
          {error.builder}
        </div>
        <div className="key">
          {error.key}
        </div>
        {error.messages.map(m=><div className="message">{m[0]} {m[1]}</div>)}
      </div>
    )
  }

  renderErrors = () => {
    return (
      <div className="BlockProvider_errors">
        <h1>ActiveBlock Validation Errors</h1>
        {this.state.blocks.errors.map(this.renderError)}
      </div>
    )
  }

  render() {
    if (this.state.blocks !== undefined) {
      const errors = this.state.blocks.errors;
      if (errors != null && errors.length > 0) {
        return this.renderErrors();
      } else {
        return this.renderApp();
      }
    }
    else {
      return "Loading Blocks";
    }
  }

}

export default BlockProvider;
