import React, { Component } from 'react';
// import PropTypes from 'prop-types';
// import { Button } from 'reactstrap';

class Toolbar extends Component {

  render() {
    return (
      <div className="react-grid-Toolbar">
        <div className="title">
          {this.props.title}
        </div>
        <div className="actions">
        {this.props.commands.map(c => (
      <button type="button" className="btn">{c.key.replace('command-','').replace(/(\_\w)/g, function(m){return ` ${m[1].toUpperCase()}`;})}</button>
    ))}
        </div>
      </div>);
  }

}

export default Toolbar;
