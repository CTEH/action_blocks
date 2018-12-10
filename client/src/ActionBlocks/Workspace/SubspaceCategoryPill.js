import React, { Component } from 'react';
import { Link } from "@reach/router"
import BlockConsumer from '../BlockConsumer';
// import WorkspaceContext from './WorkspaceContext.js';
import './SubspaceCategoryPill.css';

const NavLink = ({...props}) => (
  <Link
    {...props}
    getProps={({ isCurrent, isPartiallyCurrent }) => {
      return {
        className: `active-${isCurrent || isPartiallyCurrent}`
      };
    }}  />
);

class SubspaceCategoryPill extends Component {

  render() {
    const workspace_key = this.props.workspace_key;
    const subspace_category = this.props.subspace_category;
    const root_path = ``
    const workspace_path = `${root_path}/${workspace_key}`
    const subspace_path = `${workspace_path}/subspace-${subspace_category.category}`;

    let alternate_matches = [];
    if (subspace_category.first) {
      alternate_matches = [root_path, workspace_path];
    }

    return (
      <NavLink alternate_matches={alternate_matches} to={subspace_path}>
        {subspace_category.title}
      </NavLink>
    );
  }

}


export default BlockConsumer(SubspaceCategoryPill);
