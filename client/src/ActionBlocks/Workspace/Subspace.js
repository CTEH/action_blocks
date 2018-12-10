import React, { Component } from 'react';
import { Router, Redirect } from "@reach/router"
import RecordTitle from '../Model/RecordTitle';
import Dashboard from './Dashboard';
import DashboardCategoryTab from './DashboardCategoryTab';
import SubspaceContext from './SubspaceContext';

import './Subspace.css';

class Subspace extends Component {

  renderDefaultRoute = () => {
    // const workspace = this.props.workspace;
    const subspace = this.props.subspace;
    const default_dashboard = subspace.dashboards.find(d=>d.model==null);

    return (
      <Redirect
        noThrow
        from={`/`}
        to={`${this.props.uri}/${this.renderDashboardPath(default_dashboard)}`}
      />
    );
  }

  renderDashboardPath = (dashboard) => {
    // const workspace = this.props.workspace;
    // const subspace = this.props.subspace;

    if (dashboard.model) {
      // console.log(`${dashboard.category}/model-${dashboard.model}/:id/*`);
      return `${dashboard.category}/${dashboard.model}/:id/*`
    } else {
      // console.log(`${dashboard.category}/*`)
      return `${dashboard.category}`
    }
  }

  renderSubspaceHeader  = () => {
    if (this.props.subspace.model) {
      return (
        <h2>
          <RecordTitle
            block_key={this.props.subspace.model}
            recordId={this.props.id}
          />
        </h2>
      )
    } else {
      return (
        <h2>
          {this.props.subspace.title}
        </h2>
      )
    }
  }

  render() {
    const subspace = this.props.subspace
    const dashboards = subspace.dashboards;

    const dashboard_categories = subspace.dashboard_categories;
    const workspace = this.props.workspace;

    if(dashboards.length > 0) {
      return (
        <SubspaceContext.Provider value={this.props.id}>
          <div className="Subspace">
            <div className="header">
              {
                this.renderSubspaceHeader()
              }

              <div className="tabs">
                {dashboard_categories
                  .map(dc=><DashboardCategoryTab dashboard_category={dc} key={`${dc.category}`} />)
                }
              </div>
            </div>
            <div className="canvas">
              <Router>
                {this.renderDefaultRoute()}
                {dashboards.map(dashboard => <Dashboard
                  key={dashboard.key}
                  workspace={workspace}
                  subspace={subspace}
                  dashboard={dashboard}
                  path={`${this.renderDashboardPath(dashboard)}`}
                />)}
              </Router>
            </div>
          </div>
        </SubspaceContext.Provider>
      );
    } else {
      return (
        <SubspaceContext.Provider value={this.props.id}>
          <div className="Subspace">
            {
              this.renderSubspaceHeader()
            }
            <div className="tabs">
            </div>
          </div>
        </SubspaceContext.Provider>
      )
    }
  }

}

export default Subspace;
