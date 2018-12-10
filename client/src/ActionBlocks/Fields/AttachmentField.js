import React, { Component } from 'react';
import AttachmentFieldImg from './AttachmentFieldImg';

class AttachmentField extends Component {

  render() {
    let block = this.props.block;
    switch(block.attachment_type) {
    case 'image':
      return <AttachmentFieldImg block={block} record={this.props.record} />
    default:
      return <span>Attachment Type {block.attachment_type} Not Implemented</span>
    }
  }

}

export default AttachmentField;
