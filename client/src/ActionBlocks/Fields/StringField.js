import React, { Component } from 'react';

class StringField extends Component {

  render() {
    if (this.props.record) {
      return this.props.record[this.props.block.id];
    } else {
      return ''
    }
  }

}

export default StringField;
