import React, { Component } from "react";

import "./List.css";

class List extends Component {
  render() {
    const content = this.props.items.map((item) => {
      const disconnect = <button className="ListItemRemoveButton" onClick={() => this.props.removeAction.bind(this.props.parent)(item.id)}><strong>Disconnect</strong></button>;

      return (
        <li key={item.id}>
          <div className="ListItem">
            <div className="ListItemName">
              <img className="SmallLogo" alt="Your workspace logo" src={item.attributes.logo} />
              <span>{item.attributes.name}</span>
            </div>
            {disconnect}
          </div>
        </li>
      );
    });

    return (
      <ul className="PlainList">
        {content}
      </ul>
    );
  }
}

export default List;
