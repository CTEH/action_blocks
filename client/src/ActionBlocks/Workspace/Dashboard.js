import React, { Component } from 'react';
import Barchart from '../Barchart/Barchart.js';
import Table from '../Table/Table.js';
import MountedForm from '../MountedForm/MountedForm.js';
import './Dashboard.css';
import BlockConsumer from '../BlockConsumer.js';
import DashboardContext from './DashboardContext';

class Dashboard extends Component {


  renderDashlet = (d) => {
    switch (d.type) {
    case 'table':
      return <Table key={d.key} block_key={d.key} />
    case 'barchart':
      return <Barchart key={d.key} block_key={d.key} />
    case 'mounted_form':
      return <MountedForm key={d.key} block_key={d.key} />
    default:
      return <p key={d.key}>Block type {d.type} not implimented in Dashboard.js</p>;
    }
  }

  render() {
    const dashboard = this.props.dashboard;
    const blocks = this.props.blocks;
    const dashlets = dashboard.dashlet_keys.map(k=>blocks[k])

    return (
      <DashboardContext.Provider value={this.props.id}>
        {dashlets.map(this.renderDashlet)}
      </DashboardContext.Provider>
    );
  }

}

export default BlockConsumer(Dashboard);
