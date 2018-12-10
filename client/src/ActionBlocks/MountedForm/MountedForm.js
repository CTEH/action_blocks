import React, { Component } from 'react';
import Form from '../Form/Form.js';
import BlockConsumer from '../BlockConsumer';
import SubspaceConsumer from '../Workspace/SubspaceConsumer'
import DashboardConsumer from '../Workspace/DashboardConsumer'

class MountedForm extends Component {

  render() {
    const block = this.props.block;
    let recordId;
    if(block.mounted_to === 'dashboard') {
      recordId = this.props.dashboard_model_id;
    }
    if(block.mounted_to === 'subspace') {
      recordId = this.props.subspace_model_id;
    }
    return (
      <Form
        block_key={block.form_key}
        record_id={recordId}
        mounted_to={block.mounted_to}
      />
    );
  }

}

export default SubspaceConsumer(DashboardConsumer(BlockConsumer(MountedForm)));
