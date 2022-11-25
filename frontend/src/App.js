import { Nav } from "./components/Nav";
import { Sidebar } from "./components/Sidebar";
import { Dashboard } from "./components/Dashboard";
import { Footer } from "./components/Footer";
import { ControlSideBar } from "./components/ControlSideBar";
import { Modal } from "./components/Modal";

import { useDispatch } from "react-redux";
import { bindActionCreators } from "redux";
import { actionCreators } from "./store";

import { useEffect } from "react";

export const App = () => {
  const dispatch = useDispatch();
  const { update_donations, update_funds_approved, update_total_funds } =
    bindActionCreators(actionCreators, dispatch);

  const preload = () => {
    update_donations();
    update_funds_approved();
    update_total_funds();
  };

  useEffect(() => {
    preload();
  }, []);

  return (
    <div className="wrapper">
      <Nav />
      <Sidebar />
      <Dashboard />
      <Footer />
      <ControlSideBar />
      <Modal />
    </div>
  );
};