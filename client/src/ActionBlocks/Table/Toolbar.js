import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import { Button } from 'reactstrap';
import "./Toolbar.css";

class Toolbar extends Component {

  state = { commands: [] } 

  static propTypes = {
    title: PropTypes.string,
    commands: PropTypes.any,
    onAddRow: PropTypes.func,
    onToggleFilter: PropTypes.func,
    enableFilter: PropTypes.bool,
    numberOfRows: PropTypes.number,
    addRowButtonText: PropTypes.string,
    filterRowsButtonText: PropTypes.string,
    children: PropTypes.any
  };

  static defaultProps = {
    enableAddRow: true,
    addRowButtonText: 'Add Row',
    filterRowsButtonText: 'Filter Rows'
  };

  onAddRow = () => {
    if (this.props.onAddRow !== null && this.props.onAddRow instanceof Function) {
      this.props.onAddRow({newRowIndex: this.props.numberOfRows});
    }
  };

  renderAddRowButton = () => {
    if (this.props.onAddRow ) {
      return (<button type="button" className="btn" onClick={this.onAddRow}>
        {this.props.addRowButtonText}
      </button>);
    }
  };

  renderCommandButtons = () => {
    
  }

  // componentWillReceiveProps(props, nextProps) {
  //   this.setState({ commands: nextProps.commands, selectedRows: nextProps.selectedRows })
  //   console.log(this.state)
  //   // if (props.refresh !== refresh) {
  //   //   this.fetchShoes(id)
  //   //     .then(this.refreshShoeList)
  //   // }
  // }

  renderToggleFilterButton = () => {
    if (this.props.enableFilter) {
      return (<button type="button" className="btn" onClick={this.props.onToggleFilter}>
        {this.props.filterRowsButtonText}
      </button>);
    }
  };

  render() {
    return (
      <div className="react-grid-Toolbar">
        <div className="title">
          {this.props.title}
        </div>
        <div className="actions">
          {this.renderAddRowButton()}
          {this.renderToggleFilterButton()}
          {this.props.commands.filter(c => c.type === 'multi_record' || c.type === 'table_view').map(c => (
      <button disabled={c.type === 'multi_record' && (this.props.selectedRows === undefined || this.props.selectedRows.length == 0)} type="button" className="btn">{c.key.replace('command-','').replace(/(\_\w)/g, function(m){return ` ${m[1].toUpperCase()}`;})}</button>
    ))}
          {this.props.children}
        </div>
      </div>);
  }

}

export default Toolbar;
