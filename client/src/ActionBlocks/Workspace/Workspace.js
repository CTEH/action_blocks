import React, { Component } from 'react';
import { Router, Redirect } from "@reach/router"
import BlockConsumer from '../BlockConsumer';
import Subspace from './Subspace.js';
import WorkspaceContext from './WorkspaceContext.js';
import SubspaceCategoryPill from './SubspaceCategoryPill.js';
import './Workspace.css';

class Workspace extends Component {

  renderPill = (sc) => {
    return (
      <SubspaceCategoryPill
        key={sc.category}
        workspace_key={this.props.block_key}
        subspace_category={sc}
      />
    )
  }

  renderDefaultRoute = () => {
    const workspace = this.props.block;
    const default_subspace = workspace.subspaces.find(ss=>ss.model==null);

    // console.log('uri', this.props.uri)
    return (
      // <Subspace
      //   key={default_subspace.key}
      //   workspace={workspace}
      //   subspace={default_subspace}
      //   path={`/`}
      // />
      <Redirect
        noThrow
        from='/'
        to={`${this.props.uri}/${this.renderSubspacePath(default_subspace).replace('*', '')}`}
      />
    );
  }

  renderSubspacePath = (subspace) => {
    // const workspace = this.props.block;
    // console.log(`subspace-${subspace.category}/model-${subspace.model}/*`);

    if (subspace.model) {
      return `subspace-${subspace.category}/${subspace.model}/:id/*`
    } else {
      return `subspace-${subspace.category}/*`
    }
  }

  render() {
    const workspace = this.props.block;
    const subspace_categories = workspace.subspace_categories;
    const subspaces = workspace.subspaces;

    return (
      <WorkspaceContext.Provider value={workspace}>
        <div className="Workspace clearfix">
          <div className="left">
            <span className="title">
              {workspace.title}
            </span>
          </div>
          <div className="right">
            {subspace_categories.map(this.renderPill)}
          </div>
        </div>
        <Router>
          {this.renderDefaultRoute()}
          {subspaces.map(subspace => <Subspace
            key={`${subspace.key}-${subspace.model}`}
            workspace={workspace}
            subspace={subspace}
            path={this.renderSubspacePath(subspace)}
          />)}
        </Router>
      </WorkspaceContext.Provider>
    );
  }

}

export default BlockConsumer(Workspace);

// <Redirect noThrow from='/' to={`/${workspace.key}/${first_subspace.key}`} />
