
import React from 'react';
import DashboardContext from './DashboardContext.js';

export default (WrappedComponent) => {
  const HIC = (props) => {
    return (
      <DashboardContext.Consumer>
        {model_id => <WrappedComponent
          {...props}
          dashboard_model_id={model_id}
        />}
      </DashboardContext.Consumer>
    )
  }
  HIC.WrappedComponent = WrappedComponent;
  return HIC;
}
