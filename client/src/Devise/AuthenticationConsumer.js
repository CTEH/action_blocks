import React from 'react';
import AuthenticationContext from './AuthenticationContext';

export default (WrappedComponent) => {
  const HIC = (props) => {
    return (
      <AuthenticationContext.Consumer>
        {value => <WrappedComponent
          {...props}
          auth={value}
        />}
      </AuthenticationContext.Consumer>
    )
  }
  HIC.WrappedComponent = WrappedComponent;
  return HIC;
}
