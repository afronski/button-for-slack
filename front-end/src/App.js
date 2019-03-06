import React, { Component } from "react";

import Amplify from "aws-amplify";
import configuration from "./aws-exports";

import { withAuthenticator } from "aws-amplify-react";

import { SignOut } from "aws-amplify-react";

import ConnectedSlackWorkspacesList from "./components/ConnectedSlackWorkspacesList";
import UserProfile from "./components/UserProfile";

import "./App.css";

import Logo from "./assets/logo.png";
import PatternMatchLogo from "./assets/pattern-match.jpg";

Amplify.configure(configuration);

class App extends Component {
  render() {
    return (
      <main className="App">
        <header className="Header">
          <div className="LogoAndTitle">
            <img className="Logo" alt="Application Logo" src={Logo} />
            <h1>Button For Slack</h1>
          </div>
          <div>
            <SignOut/>
          </div>
        </header>
        <ConnectedSlackWorkspacesList url={this.props.url} />
        <hr />
        <UserProfile url={this.props.url} />
        <hr />
        <footer className="Footer">
          <img className="SmallLogo" alt="Pattern Match Logo" src={PatternMatchLogo} />
          <small>Designed and created by <em>Pattern Match</em> with &hearts;</small>
        </footer>
      </main>
    );
  }
}

const signUpConfig = {
  defaultCountryCode: "48"
};

export default withAuthenticator(App, { signUpConfig });
