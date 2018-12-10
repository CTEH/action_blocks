import React from 'react';
import SubspaceContext from './SubspaceContext.js';

export default (WrappedComponent) => {
  const HIC = (props) => {
    return (
      <SubspaceContext.Consumer>
        {model_id => <WrappedComponent
          {...props}
          subspace_model_id={model_id}
        />}
      </SubspaceContext.Consumer>
    )
  }
  HIC.WrappedComponent = WrappedComponent;
  return HIC;
}
