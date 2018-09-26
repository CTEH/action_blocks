import React, { Component, createContext, Fragment } from 'react';
import { Router, Link } from "@reach/router"
import { navigate } from "@reach/router"
import BlockConsumer from '../BlockConsumer';

import './<%=class_name%>.css';

class <%=class_name%> extends Component {

  render() {
    const block = this.props.block;
    const blocks = this.props.blocks;

    return (
      <div className="ActionBlock-<%=class_name%>">
      </div>
    );
  }

}

export default BlockConsumer(<%=class_name%>);
