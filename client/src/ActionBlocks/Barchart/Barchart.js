import React, { Component } from 'react';
// import { Link } from "@reach/router"
import { CanvasJSChart } from '../../canvasjs.react.js';
import AuthService from '../../AuthService'
import BlockConsumer from '../BlockConsumer.js';
import './Barchart.css';

class Barchart extends Component {

  state = {
    analytics: null
  }

  componentDidMount() {
    // console.log('-------- componentDidMount ----------')
    new AuthService().fetch(`/action_blocks/barchart_blocks/${this.props.block_key}/analytics.json`)
      .then(res => this.setState({analytics: res.body}))
      .catch(error => console.log(error));
  }

  getAnalytics = () => {
    if(this.state.analytics != null) {
      let data = this.state.analytics;
      let labels = Object.keys(data)

      return labels.sort().map( (label) => {
        return {
          label: label,
          y: data[label]
        };
      })
    } else {
      return {}
    }
  }

  render() {
    const block = this.props.block;
    // const blocks = this.props.blocks;

    /* eslint-disable max-len */
    const options = {
      animationEnabled: true,
      exportEnabled: true,
      theme: "light2", //"light1", "dark1", "dark2"
      title:{
        text: block.title,
        fontFamily:"-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,sans-serif",
        fontSize:20
      },
      axisX:{
        labelFontFamily:"-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,sans-serif",
        labelFontSize:10
      },
      axisY:{
        labelFontFamily:"-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,sans-serif",
        labelFontSize:10
      },

      data: [{
        type: "column", //change type to bar, line, area, pie, etc
        //indexLabel: "{y}", //Shows y value on all Data Points
        indexLabelFontColor: "#5A5757",
        indexLabelPlacement: "outside",
        dataPoints: this.getAnalytics()
      }]
    }

    if (this.state.analytics != null) {
      return <CanvasJSChart options = {options} />
    } else {
      return (
        <div>
          <h5>{this.props.block.title}</h5>
          <p>Loading Analytics ...</p>
        </div>
      )
    }
  }

}

export default BlockConsumer(Barchart);
