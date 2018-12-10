import React, { Component, Fragment } from 'react';
import { Router, Redirect } from "@reach/router"
// import { navigate } from "@reach/router"
import BootstrapBar from "./BootstrapBar.js";
import Workspace from "../Workspace/Workspace.js";
import BlockConsumer from '../BlockConsumer';

import 'bootstrap/dist/css/bootstrap.min.css';
import './colors.css';
import './Layout.css';

class Layout extends Component {

  render() {
    const block = this.props.block;
    const blocks = this.props.blocks;
    const workspaces = block.workspace_keys.map(key => blocks[key])
    // const block_keys = Object.keys(blocks);

    return (
      <Fragment>
        <BootstrapBar block_key={block.key} />
        <Router>
          {/* <Workspace path="/*" block_key={workspaces[0].key} /> */}
          <Redirect noThrow from='/' to={workspaces[0].key} />
          {workspaces.map(ws=><Workspace key={ws.key} path={`/${ws.key}/*`} block_key={ws.key} />)}
        </Router>

      </Fragment>
    );
  }

}

export default BlockConsumer(Layout);
