import React, { Component } from 'react';
import BlockConsumer from '../BlockConsumer';
import AttachmentField from './AttachmentField';

// import './teamdesk.css';
// import './Form.css';

class Field extends Component {

  state = {}

  render() {
    let block = this.props.block;
    switch(block.type) {
    case 'attachment':
      return <AttachmentField block={this.props.block} record={this.props.record} />
    default:
      if(this.props.record) {
        return this.props.record[block.id]
      } else {
        return 'Loading ...'
      }
      // return <span><i>{block.type} field not implemented</i></span>
    }
  }

}

export default BlockConsumer(Field);


// let field_block = this.props.blocks[field.field_key]
// if (this.state.record) {
//   let value = this.state.record[field_block.id];
//   if(field_block.type === 'attachment') {
//     if (this.props.block) {
//       let model_key = field_block.model_key;
//       let fieldName = field_block.id;
//       return <img src={`/attachments/${model_key}/${value}/${fieldName}`} alt={fieldName}/>;
//     }
//   } else {
//     return value;
//   }
// }      </Fragment>
