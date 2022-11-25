import { useDispatch, useSelector } from "react-redux";
import { bindActionCreators } from "redux";
import { actionCreators } from "../store";

export const Nav = () => {
  const dispatch = useDispatch();
  const { update_account } = bindActionCreators(actionCreators, dispatch);
  const account = useSelector((state) => state.account);

  const IsWalletConnected = () => {
    return (
      <button
        className="btn btn-block btn-outline-primary disabled"
        onClick={update_account}
      >
        Wallet Connected
      </button>
    );
  };

  const WalletNotConnected = () => {
    return (
      <button
        className="btn btn-block btn-outline-primary"
        onClick={update_account}
      >
        Connect Wallet
      </button>
    );
  };

  return (
    <nav className="main-header navbar navbar-expand navbar-white navbar-light">
      <ul className="navbar-nav">
        <li className="nav-item">
          <a
            className="nav-link"
            data-widget="pushmenu"
            href={false}
            role="button"
          >
            <i className="fas fa-bars"></i>
          </a>
        </li>
      </ul>
      <ul className="navbar-nav ml-auto">
        <li className="nav-item">
          {account === null ? <WalletNotConnected /> : <IsWalletConnected />}
        </li>
      </ul>
    </nav>
  );
};
