import React, { Component } from 'react';
import AuthService from '../../AuthService'

class AttachmentFieldImg extends Component {

  state = {}

  fetchImageData = (record) => {
    let block = this.props.block;
    let fieldName = block.id;
    let recordId = record[fieldName];
    let url = `/action_blocks/attachments/${block.model_key}/${recordId}/${fieldName}`;
    new AuthService().fetchBlob(url)
      .then(blob => new Promise((resolve, reject) => {
        const reader = new FileReader()
        reader.onloadend = () => resolve(reader.result)
        reader.onerror = reject
        reader.readAsDataURL(blob)
      }))
      .then(dataUrl => this.setState({ hasData: true, dataUrl: dataUrl }))
      .catch(r => this.setState({ errorMessage: r.message }))
  }

  // https://reactjs.org/blog/2018/03/27/update-on-async-rendering.html#invoking-external-callbacks
  componentDidUpdate(prevProps, prevState) {
    if (prevProps.record !== this.props.record && this.props.record) {
      this.fetchImageData(this.props.record);
      return null;
    }
  }

  render() {
    if(this.state.hasData) {
      return <img src={this.state.dataUrl} alt={this.props.block.id} />
    } else {
      return this.state.errorMessage || '';
      // <div style={{width: '200px', height: '200px', backgroundColor: 'grey', border: 'black'}} />
    }
  }

}

export default AttachmentFieldImg;
