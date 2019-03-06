import React, { Component } from "react";

import AmplifyTheme from "aws-amplify-react/dist/Amplify-UI/Amplify-UI-Theme";
import { Toast } from "aws-amplify-react/dist/Amplify-UI/Amplify-UI-Components-React";

import SignInToSlack from "./SignInToSlack";
import List from "./List";

import { externalRequestWithAuthAndCORS } from "../utils/helpers"

import "./ConnectedSlackWorkspacesList.css";

class ConnectedSlackWorkspacesList extends Component {

  constructor(props) {
    super(props);

    this.state = {
      error: null,
      isLoaded: false,
      items: []
    };
  }

  getUrl() {
    return `${this.props.url}/slack_workspaces`;
  }

  async componentDidMount() {
    fetch(this.getUrl(), await externalRequestWithAuthAndCORS("GET"))
      .then(response => response.json())
      .then(
        (result) => {
          if (result.message) {
            this.setState({
              isLoaded: true,
              error: result
            });
          } else {
            this.setState({
              isLoaded: true,
              items: result
            });
          }
        },

        (error) => {
          this.setState({
            isLoaded: true,
            error
          });
        }
      )
  }

  async removeItem(id) {
    fetch(`${this.getUrl()}/${btoa(id)}`, await externalRequestWithAuthAndCORS("DELETE"))
      .then(() => this.setState({ items: this.state.items.filter((item) => id !== item.id) }));
  }

  render() {
    const theme = this.props.theme || AmplifyTheme;
    const { error, isLoaded, items } = this.state;
    const isEmpty = isLoaded && items.length === 0;

    if (!isLoaded) {
      return (
        <div className="ConnectedSlackWorkspacesList">
          <h2>Loading...</h2>
        </div>
      );
    } else {
      return (
        <div className="ConnectedSlackWorkspacesList">
          {error &&
            <Toast theme={theme} onClose={() => this.setState({error: null})}>
              {`Error: ${error.message} at getting list of connected workspaces`}
            </Toast>
          }
          {!isEmpty && <h2>Connected workspaces:</h2>}
          <List items={items} removeAction={this.removeItem} parent={this} />
          <hr />
          <h2>Connect additional workspace:</h2>
          <SignInToSlack />
        </div>
      );
    }
  }
}

export default ConnectedSlackWorkspacesList;
