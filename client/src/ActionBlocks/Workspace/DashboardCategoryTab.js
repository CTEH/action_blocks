import React, { Component } from 'react';
import { Link } from "@reach/router"
import BlockConsumer from '../BlockConsumer';
// import WorkspaceContext from './WorkspaceContext.js';
import './DashboardCategoryTab.css';

const NavLink = ({...props}) => (
  <Link
    {...props}
    getProps={({ isCurrent, isPartiallyCurrent }) => {
      return {
        className: `active-${isCurrent || isPartiallyCurrent}`
      };
    }}  />
);

class DashboardCategoryTab extends Component {

  render() {
    // const workspace_key = this.props.workspace_key;
    const dashboard_category = this.props.dashboard_category;
    // const root_path = ``
    // const workspace_path = `${root_path}/${workspace_key}`
    // const subspace_path = `${workspace_path}/subspace-${dashboard_category.category}`;
    // const dashboard_path = `${workspace_path}/subspace-${dashboard_category.category}`
    //
    let alternate_matches = [];
    // if (dashboard_category.first) {
    //   alternate_matches = [root_path, workspace_path];
    // }

    return (
      <NavLink alternate_matches={alternate_matches} to={`./${dashboard_category.category}`}>
        {dashboard_category.title}
      </NavLink>
    );
  }

}


export default BlockConsumer(DashboardCategoryTab);
