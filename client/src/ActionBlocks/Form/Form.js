import React, { Component, Fragment } from 'react';
// import { Link } from "@reach/router"
// import { navigate } from "@reach/router"
import BlockConsumer from '../BlockConsumer';

import AuthService from '../../AuthService'
import Field from '../Fields/Field';
// import './teamdesk.css';
import './Form.css';
import Toolbar from './Toolbar.js';


class Form extends Component {

  state = {}

  componentDidMount() {
    let form_key = this.props.block_key;
    let record_id = this.props.record_id;

    new AuthService().fetch(`/action_blocks/form_blocks/${form_key}/${record_id}/record.json`)
      .then((res) => {
        this.setState({record: res.body})
        console.log(this.state.record)
      })
      .catch(error => console.log(error));
  }

  renderField = (field) => {
    return <Field
      block_key={field.field_key}
      record={this.state.record}
    />
  }

  renderFieldGroup = (field) => {
    return (
      <dl className="clearfix">
        <dt>
          {field.label}
        </dt>
        <dd>
          {this.renderField(field)}
        </dd>
      </dl>
    )
  }

  renderSection = (section) => {
    return (
      <section>
        <header>
          <h3>
            {section.title}
          </h3>
        </header>
        <div className="body">
          {section.fields.map(this.renderFieldGroup)}
        </div>
      </section>
    )
  }

  render() {
    const block = this.props.block;
    // const blocks = this.props.blocks;

    let currentWidth = 0;
    let currentRow = [];
    const rows = [];
    block.sections.forEach((section) => {
      if (section.width + currentWidth > 4) {
        rows.push(currentRow.slice(0)); // Append Copy
        currentRow = []
        currentWidth = 0;
      }
      currentRow.push(section);
      currentWidth = currentWidth + section.width;
    });
    rows.push(currentRow.slice(0));

    return (
      <Fragment>
        <div className="ActiveBlock-Form">
        <Toolbar commands={this.props.block.commands}>
      </Toolbar>
          {rows.map(row => row.map(this.renderSection))}
        </div>
      </Fragment>
    );
  }

}

export default BlockConsumer(Form);
