import React, { Component } from 'react';
import { navigate } from "@reach/router"
import ReactDataGrid from 'react-data-grid';
import { Data } from 'react-data-grid-addons';
import BlockConsumer from '../BlockConsumer.js';
import WorkspaceConsumer from '../Workspace/WorkspaceConsumer';
import SubspaceConsumer from '../Workspace/SubspaceConsumer';
import DashboardConsumer from '../Workspace/DashboardConsumer';
import Toolbar from './Toolbar.js';
import './Table.css';

import AuthService from '../../AuthService'

class Table extends Component {

  constructor(props, context) {
    super(props, context);
    // Conforms to Data.Selectors API //
    this.state = {
      rows: [], filters: {}, sortColumn: null, sortDirection: null
    };
  }

  getRows = () => {
    return Data.Selectors.getRows(this.state);
  };

  getSize = () => {
    return this.getRows().length;
  };


  rowGetter = (rowIdx) => {
    const rows = this.getRows();
    return rows[rowIdx];
  };


  record_path = (id, row) => {
    const model_key = this.props.block.model_key;
    const workspace = this.props.workspace;

    const model_paths = workspace.model_paths;
    const model_path = model_paths[model_key]

    let path;

    if (model_path.path_type === 'dashboard') {
      const subspace_record_id = row[`${model_path.subspace_model}_id`.replace('model-','')];
      // eslint-disable-next-line max-len
      path = `/${workspace.key}/${model_path.subspace_key}/${model_path.subspace_model}/${subspace_record_id}/${model_path.dashboard_category}/${model_path.dashboard_model}/${id}`
    }
    else if (model_path.path_type === 'subspace') {
      path = `/${workspace.key}/${model_path.subspace_key}/${model_path.subspace_model}/${id}`
    }

    return path;
  }

  columns = () => {
    const action_column = {
      key: 'id',
      name: 'Action',
      filterable: false,
      sortable: false,
      resizable: true,
      // width: 55,
      getRowMetaData: row => row,
      formatter: ({ value, dependentValues }) =>
        <div className="actions">
          <button type="button"
            className="btn"
            onClick={()=>navigate(this.record_path(value, dependentValues))}
          >
            View
          </button>
          {
            this.props.block.commands.filter(c => c.type === 'record').map(c => (
              <button type="button"
              className="btn">{c.key.replace('command-','').replace(/(_\w)/g, function(m){return ` ${m[1].toUpperCase()}`;})}</button>
            ))
          }
        </div>
    };
    const data_columns = this.props.block.column_keys.map((key) => {
      return {key: key, name: key, filterable: true, sortable: true};
    }).filter(k => !k.key.endsWith('_id') && k.key !== 'id');
    return [action_column].concat(data_columns);
  }

  handleFilterChange = (filter) => {
    let newFilters = Object.assign({}, this.state.filters);
    if (filter.filterTerm) {
      newFilters[filter.column.key] = filter;
    } else {
      delete newFilters[filter.column.key];
    }

    this.setState({ filters: newFilters });
  };

  handleGridSort = (sortColumn, sortDirection) => {
    this.setState({ sortColumn: sortColumn, sortDirection: sortDirection });
  };

  onClearFilters = () => {
    this.setState({ filters: {} });
  };

  renderDataGrid = () => {
    if (this.state.rows) {
      return  (
        <ReactDataGrid
          onGridSort={this.handleGridSort}
          columns={this.columns()}
          rowGetter={this.rowGetter}
          rowsCount={this.getSize()}
          toolbar={this.toolbar()}
          onAddFilter={this.handleFilterChange}
          onClearFilters={this.onClearFilters}
          onRowSelect ={(rows) => {
            console.log(rows)
            this.setState({ selectedRows: rows.map(r => r.id) });
          }}
          enableRowSelect
        />
      );
    } else {
      return "Loading..."
    }
  }

  renderRowCount = () => {
    if (this.state.rows) {
      return <div className="active-block-TableFooter">{this.getSize()} Records</div>;
    }
  }

  toolbar = () => {
    return (
      <Toolbar title={this.props.block.title} selectedRows={this.state.selectedRows} commands={this.props.block.commands} enableFilter={true}>
      </Toolbar>
    )
  }

  componentDidMount() {
    // console.log('-------- componentDidMount ----------')
    new AuthService().fetch(`/action_blocks/table_blocks/${this.props.block_key}${
      this.props.subspace_model_id ? `/${this.props.subspace_model_id}` : ''}${
      this.props.dashboard_model_id ? `/${this.props.dashboard_model_id}` : ''}/records.json`)
      .then(res => this.setState({rows: res.body}))
      .catch(error => console.log(error));
  }

  render() {
    // const blocks = this.props.blocks;
    // const block = this.props.block;

    return (
      <div className="active-block-Table">
        {this.renderDataGrid()}
        {this.renderRowCount()}
      </div>
    );
  }

}

export default WorkspaceConsumer(SubspaceConsumer(DashboardConsumer(BlockConsumer(Table))));
