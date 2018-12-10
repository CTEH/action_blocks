import React, { Component, Fragment } from 'react';
import BlockConsumer from '../BlockConsumer.js';

import AuthService from '../../AuthService'

class RecordTitle extends Component {

  constructor(props, context) {
    super(props, context);
    // Conforms to Data.Selectors API //
    this.state = {};
  }

  componentDidMount() {
    // console.log('-------- componentDidMount ----------')
    new AuthService().fetch(`/action_blocks/model_blocks/${this.props.block_key}/${this.props.recordId}/name`)
      .then(res => this.setState({data: res.body}))
      .catch(error => console.log({error: error}));
  }

  render() {
    // const blocks = this.props.blocks;
    // const block = this.props.block;

    return (
      <Fragment>
        {this.props.block.singular_name}: { this.state.data ? this.state.data[this.props.block.name_field] : '' }
      </Fragment>
    );
  }

}

export default BlockConsumer(RecordTitle);
