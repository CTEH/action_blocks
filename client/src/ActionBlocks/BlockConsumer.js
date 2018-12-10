import React from 'react';
import BlockContext from './BlockContext.js';

export default (WrappedComponent) => {
  const HIC = (props) => {
    return (
      <BlockContext.Consumer>
        {blocks => <WrappedComponent
          {...props}
          blocks={blocks}
          block={blocks[props.block_key]}
        />}
      </BlockContext.Consumer>
    )
  }
  HIC.WrappedComponent = WrappedComponent;
  return HIC;
}
