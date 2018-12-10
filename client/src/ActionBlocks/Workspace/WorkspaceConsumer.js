import React from 'react';
import WorkspaceContext from './WorkspaceContext.js';

export default (WrappedComponent) => {
  const HIC = (props) => {
    return (
      <WorkspaceContext.Consumer>
        {workspace => <WrappedComponent
          {...props}
          workspace={workspace}
        />}
      </WorkspaceContext.Consumer>
    )
  }
  HIC.WrappedComponent = WrappedComponent;
  return HIC;
}
